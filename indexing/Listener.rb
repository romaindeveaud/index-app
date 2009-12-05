require 'rexml/document'
require 'rexml/streamlistener'
include REXML

class Listener
    include StreamListener

    def initialize(dico, post_file, stoplist, listing)
        @current_file = nil
        @name         = nil
        @isName       = nil
        @dico_indice  = 0
        @offset       = Array.new
        @stoplist     = Array.new
        @array        = Array.new
        @post_array   = Array.new
        @d_array      = Hash.new
        @hf_pointing  = Hash.new("")
        @listing      = Hash.new
        @dico         = File.new(dico, File::CREAT|File::TRUNC|File::RDWR, 0644)
        @posting_file = File.new(post_file, File::CREAT|File::TRUNC|File::RDWR, 0644)
        @listing_file = File.new(listing, File::CREAT|File::TRUNC|File::RDWR, 0644)
        stopfile      = File.new(stoplist, File::RDONLY)
        @stoplist     = stopfile.readlines.each { |word| word.chomp! }
    end

    def set_current_file (file)
        @current_file = file.chomp".xml"
        @array.clear
    end

    def tag_start(name, attributes)
        case name
            when "name"
              @isName = 1
            when "collectionlink"
              @hf_pointing[attributes["xlink:href"].chomp!(".xml")] += @current_file+" "
        end
    end

    def text (text)
        if !@isName.nil?
            @name = String.new(text)
            @isName = nil
        end

        text.gsub!(/(\s|\W)+/u,' ')
        sentence = text.split
        sentence.compact!

        if !sentence.nil?
            sentence.each do |word| 
                clean(word)
                insert(word)
            end
        end

    end

    def clean (word)
        word.strip!
        word.downcase!
    end
    
    def insert (word)
        if !@stoplist.include?(word) && word != ""
            @array << word
        end
    end

    def inverse_doc_freq (df)
        return (Math.log(1000/df.to_i) + 1)
    end

    def weight (tf, df)
        return tf*inverse_doc_freq(df)
    end

    def index_now
#        @post_array.collect! do |post|
#            buff = post.split
#            df = buff.length
#            post = ""
#            buff.each do |b|
#                buff2 = b.split(":")
#                b = "#{b}#{weight(buff2[0].to_i,df).to_s} "
#                post = "#{post} #{b}"
#            end
#            post.lstrip!
#            post
#        end
        @d_array = @d_array.sort
        @d_array.each { |word| @dico.puts "#{word[0]} #{word[1]}" }
        @post_array.each { |post| @posting_file.puts post }
        list = Array.new
        @listing.each { |file, value| list << "#{file}:#{value}:#{@hf_pointing[file]}" }
        list.each { |post| @listing_file.puts post }
    end
    
    def display
        # ce tableau est là pour éviter qu'une entrée dans le posting file
        # soit dupliquée si le mot apparait plusieurs fois.
        uniq = Hash.new
        @listing[@current_file] = "#{@array.length}:#{@name}"
        
        @array.each do |word|
            # si c'est la première fois qu'on rencontre ce mot...
            if !@d_array.has_key?(word)#!pos
                temp = @array.grep(word)
                @post_array << "#{temp.length.to_s}:#{@current_file}"
                @d_array[word] = (@post_array.length-1).to_s
                uniq[word] = 1
            # sinon c'est qu'il est déjà dans le dico...
            else
                if !uniq[word]
                    temp = @array.grep(word)
                    @post_array[@d_array[word].to_i] += " #{temp.length.to_s}:#{@current_file}:" 
                    uniq[word] = 1
                end
            end
        end
    end
end

