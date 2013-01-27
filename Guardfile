# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'shell' do
  watch(%r{src/ly/jamie/snake}) do 
    result = `make 2>&1`
    errors = /(\w+\.as)\((\d+)\)(.+)/.match result
    if errors.nil? || errors.captures.nil?
      n "Build successful"
    else
      n errors.captures, 'make'
    end
    result
  end
end

