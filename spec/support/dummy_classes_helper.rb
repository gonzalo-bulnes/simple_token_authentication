# Create dummy classes to test modules with RSpec
#
# Usage:
#
#    describe SimpleTokenAuthentication::ModuleUnderTest do
#
#      after(:each) do
#        ensure_examples_independence
#      end
#
#      before(:each) do
#        define_test_subjects_for_inclusion_of(SimpleTokenAuthentication::ModuleUnderTest)
#      end
#
#      # spec examples...
#
#    end
##


# Returns a dummy class which includes the module under test.
def define_dummy_class_which_includes(module_under_test)
  unless defined? SimpleTokenAuthentication::SomeClass
    SimpleTokenAuthentication.const_set(:SomeClass, Class.new)
  end
  SimpleTokenAuthentication::SomeClass.send :include, module_under_test
  SimpleTokenAuthentication::SomeClass
end

# Returns a dummy class which extends the module under test.
def define_dummy_class_which_extends(module_under_test)
  unless defined? SimpleTokenAuthentication::SomeClass
    SimpleTokenAuthentication.const_set(:SomeClass, Class.new)
  end
  SimpleTokenAuthentication::SomeClass.send :extend, module_under_test
  SimpleTokenAuthentication::SomeClass
end

# Returns a dummy class which inherits from parent_class.
def define_dummy_class_child_of(parent_class)
  unless defined? SimpleTokenAuthentication::SomeChildClass
    SimpleTokenAuthentication.const_set(:SomeChildClass, Class.new(parent_class))
  end
  SimpleTokenAuthentication::SomeChildClass
end

def ensure_examples_independence
  SimpleTokenAuthentication.send(:remove_const, :SomeClass)
  SimpleTokenAuthentication.send(:remove_const, :SomeChildClass)
end

# Must be used in coordination with ensure_examples_independence
def define_test_subjects_for_inclusion_of(module_under_test)
  klass       = define_dummy_class_which_includes(module_under_test)
  child_klass = define_dummy_class_child_of(klass)

  # all specs must apply to classes which include the module and their children
  @subjects   = [klass, child_klass]
end

# Must be used in coordination with ensure_examples_independence
def define_test_subjects_for_extension_of(module_under_test)
  klass       = define_dummy_class_which_extends(module_under_test)
  child_klass = define_dummy_class_child_of(klass)

  # all specs must apply to classes which extend the module and their children
  @subjects   = [klass, child_klass]
end

def double_user_model
  user = double()
  stub_const('User', user)
  allow(user).to receive(:name).and_return('User')
end

def double_super_admin_model
  super_admin = double()
  stub_const('SuperAdmin', super_admin)
  allow(super_admin).to receive(:name).and_return('SuperAdmin')
end
