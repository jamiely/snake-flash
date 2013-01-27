# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'shell' do
  watch(%r{src/ly/jamie/snake}) do 
    result = `make 2>&1`
    errors = /(\w+\.as)\((\d+)\)(.+)/.match result
    n errors.captures, 'make' unless errors.nil? || errors.captures.nil?
    result
  end
end

