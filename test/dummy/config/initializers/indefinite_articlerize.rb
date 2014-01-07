# http://stackoverflow.com/questions/5381738/rails-article-helper-a-or-an
def indefinite_articlerize(params_word)
  %w(a e i o u).include?(params_word[0].downcase) ? "an #{params_word}" : "a #{params_word}"
end
