class SearchController < ApplicationController

def initialize
    @name  = Hash.new
    @point = Hash.new(0)
    @exact_match = Array.new
end

def index
end

def searching
    beginning = Time.now
    @request = params[:request].nil? ? session[:request] : String.new(params[:request])
    session[:request] = @request
    @request.gsub!(/(\s|\W)+/u,' ')
    @request = @request.split
    
    clean(@request)
    filter(@request)
    @request.compact!
    
    @title = params[:title]
    @linking = params[:linking]
    @doclist = search_alg(@request, @title, @linking)
    @name = get_name
    @ending = Time.now - beginning
    @offset = params[:offset]
end

def show
    require 'rexml/document'
    require 'lib/xmllistener.rb'
    listener = XMLlistener.new
    @file = File.new("indexing/20060130_french/"+params[:id]+".xml")
    parser = Parsers::StreamParser.new(@file, listener)
    parser.parse
    @final = listener.get_doc
end


# private methods bellow ~ 
private
def clean (array)
    array.each do |word|
        word.strip!
        word.downcase!
    end
    array
end

def weight(nmi)
    return Math.log((110830-nmi+0.5)/(nmi+0.5))/Math.log(2)
end

def kFunc(l, lmoy)
    return 2*((1-0.75)+0.75*(l/lmoy))
end

def filter (array)
    array.collect! do |word|
        if @@stoplist.include?(word)
            word = nil
        end
        word
    end
    array
end

def search_alg(request, isTitle, isLinking)
score2 = Hash.new

request.each do |key|

    if !isTitle.nil?
        @@name.each do |doc,title|
            score2[doc] = score2[doc].to_i+1 if !title.nil? && title.downcase.split.include?(key)
        end
    
    else
        if !@@dico.assoc(key).nil?
            line = @@posting_file[@@dico.assoc(key)[1].to_i]
            termfreq = Hash.new
            line.each { |post| termfreq[post.split(":")[1]] = post.split(":")[0] }
            
            termfreq.each_key do |doc|
                score2[doc] = score2[doc].to_f + 
                weight(termfreq[doc].to_f)*((3*termfreq[doc].to_f)/(kFunc(@@list[doc].split(":")[0].to_f,@@lmoy)+termfreq[doc].to_f))*((9*1)/(8+1))
            
            end

# La boucle ci-dessous permet d'augmenter le score d'un document s'il est pointé
# par des documents faisant partie des résultats de la requête.
            termfreq.each_key do |doc|
                if !@@pointed[doc].nil? && isLinking.nil?
                    sDT = i = 0
                    @@pointed[doc].split.uniq.each do |pointing_doc|
                        if score2.include?(pointing_doc) && pointing_doc != doc
                            @point[doc] += 1
                            i += 1
                            tmp = Math.sqrt(score2[pointing_doc].to_f)#/(Math.log(score2[pointing_doc].to_f)/Math.log(2))
                            sDT += (tmp/((Math.log(tmp+1)/Math.log(2))+1))
                        end
                    end
                    score2[doc] = score2[doc] * 1-(1/((Math.log(i+1)/Math.log(2))+1))
                    score2[doc] += (1/((Math.log(i+1)/Math.log(2))+1))*sDT
                end
            end
        end
    end
end

# La boucle ci-dessous permet d'augmenter le score d'un document si son titre
# contient des mots-clés de la requête.
request.each do |key|
    score2.each_key do |doc|
        if !@@name[doc].nil? && @@name[doc].downcase.split.include?(key)
            score2[doc] += Math.log(score2[doc]+1)/Math.log(2)
        end
        if !@@name[doc].nil?
            tmp = @@name[doc].gsub(/(\s|\W)+/u,' ').split
            clean(tmp)
            filter(tmp)
            tmp.compact!
            @exact_match.push(doc) if (request == tmp)
        end
    end
end

@exact_match.uniq!
score2 = score2.sort { |a,b| b[1]<=>a[1] }
@name = @@name
return score2
end

def get_name
    return @name
end

end
