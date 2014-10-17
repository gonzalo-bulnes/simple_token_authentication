require 'spec_helper'

describe 'Simple Token Authentication' do

  describe ':header_names option', header_names_option: true do

    describe 'determines which header fields are looked at for authentication credentials' do

      before(:each) do
        user = double()
        stub_const('User', user)
        user.stub(:name).and_return('User')

        admin = double()
        stub_const('Admin', admin)
        admin.stub(:name).and_return('Admin')

        # given one *c*orrect record (which is supposed to get signed in)
        @charles_record = double()
        [user, admin].each do |model|
          model.stub(:find_by).with(email: 'charles@example.com').and_return(@charles_record)
        end
        @charles_record.stub(:authentication_token).and_return('ch4rlEs_toKeN')

        # and one *w*rong record (which should not be signed in)
        @waldo_record = double()
        [user, admin].each do |model|
          model.stub(:find_by).with(email: 'waldo@example.com').and_return(@waldo_record)
        end
        @waldo_record.stub(:authentication_token).and_return('w4LdO_toKeN')

        # given a controller class which acts as token authentication handler
        @controller_class = Class.new
        @controller_class.stub(:before_filter)
        @controller_class.send :extend, SimpleTokenAuthentication::ActsAsTokenAuthenticationHandler

        @controller = @controller_class.new
        @controller.stub(:sign_in_handler).and_return(:sign_in_handler)
      end


      context 'provided the controller handles authentication for User' do

        before(:each) do
          # and handles authentication for a given model
          @controller_class.acts_as_token_authentication_handler_for User
        end

        context 'and params contains no authentication credentials' do

          before(:each) do
            # and there are no credentials in params
            @controller.stub(:params).and_return({})
          end

          context 'and request headers contain credentials in the custom and default fields' do

            before(:each) do
              # request headers are set in the nested contexts, these are minor settings
              @controller.stub_chain(:request, :headers).and_return(double())
              @controller.stub(:sign_in_handler).and_return(:sign_in_handler)
            end

            context 'when {}' do

              before(:each) do
                # and credentials in the default header fields lead to the wrong record
                allow(@controller.request.headers).to receive(:[]).with('X-CustomEmail')
                                                          .and_return('waldo@example.com')
                allow(@controller.request.headers).to receive(:[]).with('X-Admin-Email')
                                                          .and_return('waldo@example.com')
                allow(@controller.request.headers).to receive(:[]).with('X-Custom_Token')
                                                          .and_return('w4LdO_toKeN')
                allow(@controller.request.headers).to receive(:[]).with('X-Admin-Token')
                                                          .and_return('w4LdO_toKeN')
                # while credential in the custom header fields lead to the correct record
                allow(@controller.request.headers).to receive(:[]).with('X-User-Email')
                                                          .and_return('charles@example.com')
                allow(@controller.request.headers).to receive(:[]).with('X-User-Token')
                                                          .and_return('ch4rlEs_toKeN')

                SimpleTokenAuthentication.stub(:header_names)
                  .and_return({})
              end

              it 'does look for credentials in the default header fields (\'X-User-Email\' and \'X-User-Token\')', public: true do
                expect(@controller).to receive(:perform_sign_in!).with(@charles_record, :sign_in_handler)
                @controller.authenticate_user_from_token
              end

              it 'ignores credentials in any other fields', public: true do
                expect(@controller).not_to receive(:perform_sign_in!).with(@waldo_record, :sign_in_handler)
                @controller.authenticate_user_from_token
              end
            end

            context 'when { user: {} }' do

              before(:each) do
                # and credentials in the default header fields lead to the wrong record
                allow(@controller.request.headers).to receive(:[]).with('X-CustomEmail')
                                                          .and_return('waldo@example.com')
                allow(@controller.request.headers).to receive(:[]).with('X-Admin-Email')
                                                          .and_return('waldo@example.com')
                allow(@controller.request.headers).to receive(:[]).with('X-Custom_Token')
                                                          .and_return('w4LdO_toKeN')
                allow(@controller.request.headers).to receive(:[]).with('X-Admin-Token')
                                                          .and_return('w4LdO_toKeN')
                # while credential in the custom header fields lead to the correct record
                allow(@controller.request.headers).to receive(:[]).with('X-User-Email')
                                                          .and_return('charles@example.com')
                allow(@controller.request.headers).to receive(:[]).with('X-User-Token')
                                                          .and_return('ch4rlEs_toKeN')

                SimpleTokenAuthentication.stub(:header_names)
                  .and_return({ user: {} })
              end

              it 'does look for credentials in the default header fields (\'X-User-Email\' and \'X-User-Token\')', protected: true do
                expect(@controller).to receive(:perform_sign_in!).with(@charles_record, :sign_in_handler)
                @controller.authenticate_user_from_token
              end

              it 'ignores credentials in any other fields', protected: true do
                expect(@controller).not_to receive(:perform_sign_in!).with(@waldo_record, :sign_in_handler)
                @controller.authenticate_user_from_token
              end
            end

            context 'when { user: { email: \'X-CustomEmail\', authentication_token: \'X-Custom_Token\' } }' do

              before(:each) do
                # and credentials in the default header fields lead to the wrong record
                allow(@controller.request.headers).to receive(:[]).with('X-User-Email')
                                                          .and_return('waldo@example.com')
                allow(@controller.request.headers).to receive(:[]).with('X-User-Token')
                                                          .and_return('w4LdO_toKeN')
                # while credential in the custom header fields lead to the correct record
                allow(@controller.request.headers).to receive(:[]).with('X-CustomEmail')
                                                          .and_return('charles@example.com')
                allow(@controller.request.headers).to receive(:[]).with('X-Custom_Token')
                                                          .and_return('ch4rlEs_toKeN')

                SimpleTokenAuthentication.stub(:header_names)
                  .and_return({ user: { email: 'X-CustomEmail',
                                        authentication_token: 'X-Custom_Token' } })
              end

              it 'does look for credentials in the custom headers fields', public: true do
                expect(@controller).to receive(:perform_sign_in!).with(@charles_record, :sign_in_handler)
                @controller.authenticate_user_from_token
              end

              it 'ignores credentials in any other fields (including default ones)', public: true do
                expect(@controller).not_to receive(:perform_sign_in!).with(@waldo_record, :sign_in_handler)
                @controller.authenticate_user_from_token
              end
            end

            context 'when { admin: { email: \'X-CustomEmail\', authentication_token: \'X-Custom_Token\' } }' do

              before(:each) do
                # and credentials in the default header fields lead to the wrong record
                allow(@controller.request.headers).to receive(:[]).with('X-CustomEmail')
                                                          .and_return('waldo@example.com')
                allow(@controller.request.headers).to receive(:[]).with('X-Custom_Token')
                                                          .and_return('w4LdO_toKeN')
                # while credential in the custom header fields lead to the correct record
                allow(@controller.request.headers).to receive(:[]).with('X-User-Email')
                                                          .and_return('charles@example.com')
                allow(@controller.request.headers).to receive(:[]).with('X-User-Token')
                                                          .and_return('ch4rlEs_toKeN')

                SimpleTokenAuthentication.stub(:header_names)
                  .and_return({ admin: { email: 'X-CustomEmail',
                                        authentication_token: 'X-Custom_Token' } })
              end

              it 'does look for credentials in the default header fields for :user', public: true do
                expect(@controller).to receive(:perform_sign_in!).with(@charles_record, :sign_in_handler)
                @controller.authenticate_user_from_token
              end

              it 'ignores credentials in the custom :admin header fields', public: true do
                expect(@controller).not_to receive(:perform_sign_in!).with(@waldo_record, :sign_in_handler)
                @controller.authenticate_user_from_token
              end
            end

            context 'when { user: { email: \'X-CustomEmail\' }, admin: { authentication_token: \'X-Custom_Token\' } }' do

              before(:each) do
                # and credentials in the default header fields lead to the wrong record
                allow(@controller.request.headers).to receive(:[]).with(nil)
                                                          .and_return(nil)
                allow(@controller.request.headers).to receive(:[]).with('X-Admin-Email')
                                                          .and_return('waldo@example.com')
                allow(@controller.request.headers).to receive(:[]).with('X-Custom_Token')
                                                          .and_return('w4LdO_toKeN')
                # while credential in the custom header fields lead to the correct record
                allow(@controller.request.headers).to receive(:[]).with('X-CustomEmail')
                                                          .and_return('charles@example.com')
                allow(@controller.request.headers).to receive(:[]).with('X-User-Token')
                                                          .and_return('ch4rlEs_toKeN')

                SimpleTokenAuthentication.stub(:header_names)
                  .and_return({ user:  { email: 'X-CustomEmail' },
                                admin: { authentication_token: 'X-Custom_Token' } })
              end

              it 'does look for credentials in \'X-CustomEmail\' and \'X-User-Token\'', public: true do
                #pending 'Not yet fixed'
                expect(@controller).to receive(:perform_sign_in!).with(@charles_record, :sign_in_handler)
                @controller.authenticate_user_from_token
              end

              it 'ignores credentials in \'X-User-Email\' and the :admin header fields', public: true do
                expect(@controller).not_to receive(:perform_sign_in!).with(@waldo_record, :sign_in_handler)
                @controller.authenticate_user_from_token
              end
            end

            context 'when { admin: { email: \'X-CustomEmail\' }, user: { authentication_token: \'X-Custom_Token\' } }' do

              before(:each) do
                # and credentials in the default header fields lead to the wrong record
                allow(@controller.request.headers).to receive(:[]).with(nil)
                                                          .and_return(nil)
                allow(@controller.request.headers).to receive(:[]).with('X-CustomEmail')
                                                          .and_return('waldo@example.com')
                allow(@controller.request.headers).to receive(:[]).with('X-Admin-Email')
                                                          .and_return('waldo@example.com')
                allow(@controller.request.headers).to receive(:[]).with('X-Custom_Token')
                                                          .and_return('w4LdO_toKeN')
                # while credential in the custom header fields lead to the correct record
                allow(@controller.request.headers).to receive(:[]).with('X-User-Email')
                                                          .and_return('charles@example.com')
                allow(@controller.request.headers).to receive(:[]).with('X-Custom_Token')
                                                          .and_return('ch4rlEs_toKeN')

                SimpleTokenAuthentication.stub(:header_names)
                  .and_return({ admin:  { email: 'X-CustomEmail' },
                                user: { authentication_token: 'X-Custom_Token' } })
              end

              it 'does look for credentials in \'X-User-Email\' and \'X-Custom_Token\'', public: true do
                #pending 'Not yet fixed'
                expect(@controller).to receive(:perform_sign_in!).with(@charles_record, :sign_in_handler)
                @controller.authenticate_user_from_token
              end

              it 'ignores credentials in \'X-User-Token\' and the :admin header fields', public: true do
                expect(@controller).not_to receive(:perform_sign_in!).with(@waldo_record, :sign_in_handler)
                @controller.authenticate_user_from_token
              end
            end

            context 'when { user: { email: \'X-CustomEmail\' } }' do

              before(:each) do
                # and credentials in the default header fields lead to the wrong record
                @controller.stub_chain(:request, :headers).and_return(double())
                allow(@controller.request.headers).to receive(:[]).with(nil)
                                                          .and_return(nil)
                allow(@controller.request.headers).to receive(:[]).with('X-User-Email')
                                                          .and_return('waldo@example.com')
                allow(@controller.request.headers).to receive(:[]).with('X-Admin-Email')
                                                          .and_return('waldo@example.com')
                allow(@controller.request.headers).to receive(:[]).with('X-Admin-Token')
                                                          .and_return('w4LdO_toKeN')
                # while credential in the custom header fields lead to the correct record
                allow(@controller.request.headers).to receive(:[]).with('X-CustomEmail')
                                                          .and_return('charles@example.com')
                allow(@controller.request.headers).to receive(:[]).with('X-User-Token')
                                                          .and_return('ch4rlEs_toKeN')

                SimpleTokenAuthentication.stub(:header_names)
                  .and_return({ user:  { email: 'X-CustomEmail' } })
              end

              it 'does look for credentials in \'X-CustomEmail\' and \'X-User-Token\'', public: true do
                #pending 'Not yet fixed'
                expect(@controller).to receive(:perform_sign_in!).with(@charles_record, :sign_in_handler)
                @controller.authenticate_user_from_token
              end

              it 'ignores credentials in \'X-User-Email\' and the :admin header fields', public: true do
                expect(@controller).not_to receive(:perform_sign_in!).with(@waldo_record, :sign_in_handler)
                @controller.authenticate_user_from_token
              end
            end
          end
        end
      end

      context 'provided the controller handles authentication for Admin' do

        before(:each) do
          # and handles authentication for a given model
          @controller_class.acts_as_token_authentication_handler_for Admin
        end

        context 'and params contains no authentication credentials' do

          before(:each) do
            # and there are no credentials in params
            @controller.stub(:params).and_return({})
          end

          context 'and request headers contain credentials in the custom and default fields' do

            before(:each) do
              # request headers are set in the nested contexts, these are minor settings
              @controller.stub_chain(:request, :headers).and_return(double())
              @controller.stub(:sign_in_handler).and_return(:sign_in_handler)
            end

            context 'when { admin: { email: \'X-CustomEmail\', authentication_token: \'X-Custom_Token\' } }' do

              before(:each) do
                # and credentials in the default header fields lead to the wrong record
                @controller.stub_chain(:request, :headers).and_return(double())
                allow(@controller.request.headers).to receive(:[]).with(nil)
                                                          .and_return(nil)
                allow(@controller.request.headers).to receive(:[]).with('X-Admin-Email')
                                                          .and_return('waldo@example.com')
                allow(@controller.request.headers).to receive(:[]).with('X-User-Email')
                                                          .and_return('waldo@example.com')

                allow(@controller.request.headers).to receive(:[]).with('X-Admin-Token')
                                                          .and_return('w4LdO_toKeN')
                allow(@controller.request.headers).to receive(:[]).with('X-User-Token')
                                                          .and_return('w4LdO_toKeN')
                # while credential in the custom header fields lead to the correct record
                allow(@controller.request.headers).to receive(:[]).with('X-CustomEmail')
                                                          .and_return('charles@example.com')
                allow(@controller.request.headers).to receive(:[]).with('X-Custom_Token')
                                                          .and_return('ch4rlEs_toKeN')

                SimpleTokenAuthentication.stub(:header_names)
                  .and_return({ admin:  { email: 'X-CustomEmail', authentication_token: 'X-Custom_Token' } })
              end

              it 'does look for credentials in \'X-CustomEmail\' and \'X-Custom_Token\'', public: true do
                #pending 'Not yet fixed'
                expect(@controller).to receive(:perform_sign_in!).with(@charles_record, :sign_in_handler)
                @controller.authenticate_admin_from_token
              end

              it 'ignores credentials in \'X-Admin-Email\', \'X-Admin-Token\' and the :user header fields', public: true do
                expect(@controller).not_to receive(:perform_sign_in!).with(@waldo_record, :sign_in_handler)
                @controller.authenticate_admin_from_token
              end
            end

            context 'when { admin: { email: \'X-CustomEmail\' } }' do

              before(:each) do
                # and credentials in the default header fields lead to the wrong record
                @controller.stub_chain(:request, :headers).and_return(double())
                allow(@controller.request.headers).to receive(:[]).with(nil)
                                                          .and_return(nil)
                allow(@controller.request.headers).to receive(:[]).with('X-Admin-Email')
                                                          .and_return('waldo@example.com')
                allow(@controller.request.headers).to receive(:[]).with('X-User-Email')
                                                          .and_return('waldo@example.com')
                allow(@controller.request.headers).to receive(:[]).with('X-User-Token')
                                                          .and_return('w4LdO_toKeN')
                # while credential in the custom header fields lead to the correct record
                allow(@controller.request.headers).to receive(:[]).with('X-CustomEmail')
                                                          .and_return('charles@example.com')
                allow(@controller.request.headers).to receive(:[]).with('X-Admin-Token')
                                                          .and_return('ch4rlEs_toKeN')

                SimpleTokenAuthentication.stub(:header_names)
                  .and_return({ admin:  { email: 'X-CustomEmail' } })
              end

              it 'does look for credentials in \'X-CustomEmail\' and \'X-Admin-Token\'', public: true do
                #pending 'Not yet fixed'
                expect(@controller).to receive(:perform_sign_in!).with(@charles_record, :sign_in_handler)
                @controller.authenticate_admin_from_token
              end

              it 'ignores credentials in \'X-Admin-Email\' and the :user header fields', public: true do
                expect(@controller).not_to receive(:perform_sign_in!).with(@waldo_record, :sign_in_handler)
                @controller.authenticate_admin_from_token
              end
            end
          end
        end
      end
    end
  end
end
