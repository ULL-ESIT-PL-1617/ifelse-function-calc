PEGJS = "pegjs"
task :default => :exe

desc "Compile arithmetics.pegjs"
task :compile do
  sh "#{PEGJS} arithmetics.pegjs"
end

desc "Run and use the parser generated from arithmetics.pegjs"
task :exe => :compile do
  sh "node main.js"
end

desc "Run and use the parser generated from arithmetics.pegjs"
task :run => :compile do
  sh "node mainfromfile.js input2"
end

desc "clean derived files"
task :clean do
  sh "rm arithmetics.js"
end


