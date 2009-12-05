require 'Listener.rb'

listener = Listener.new("dico", "posting_file", "stoplist", "listing")
path = "../20060130_french/"
dir = Dir.new(path)
i = 0
size = 0
beginning = Time.now
dir.each do |file|
    if i%100 == 0
        puts " ==> Time elapsed : #{Time.now - beginning}s (#{i} files indexed)." 
    end
    if file != "." && file != ".."
        puts "Indexing file #{file}..."
        listener.set_current_file(file)
        parser = Parsers::StreamParser.new(File.new(path + file), listener)
        size += File.size(path+file)
        parser.parse
        listener.display
        i += 1
    end
end
listener.index_now
puts " ==> Time elapsed : #{Time.now - beginning}s for indexing #{i} files (#{size} bytes)." 
