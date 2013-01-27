guard 'shell' do
  watch(%r{src/ly/jamie/snake}) do 
    result = `make 2>&1`
    errors = /(\w+\.as)\((\d+)\)(.+)/.match result
    if errors.nil? || errors.captures.nil?
      n "Build successful"
    else
      # if there are errors then display the first one
      n errors.captures, 'make'
    end
    result
  end
end

