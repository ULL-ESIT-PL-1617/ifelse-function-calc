PEGJS = "pegjs"
task :default => :run

desc "Compile arithmetics.pegjs"
task :compile do
  sh "#{PEGJS} arithmetics.pegjs"
end

desc "Run and use the parser generated from arithmetics.pegjs"
task :exe => :compile do
  sh "node --harmony_destructuring main.js"
end

desc "Run and use the parser generated from arithmetics.pegjs"
task :run => :compile do
  sh "node --harmony_destructuring mainfromfile.js input1"
end

desc "clean derived files"
task :clean do
  sh "rm arithmetics.js"
end


