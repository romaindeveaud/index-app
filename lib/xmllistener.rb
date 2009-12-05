require 'rexml/document'
require 'rexml/streamlistener'
include REXML

class XMLlistener
   include StreamListener

   def initialize
    @finaldoc = String.new
    @conversionwarning = nil
    @spaceneeded = nil
   end

   def tag_start(name, attributes)
    case name
        when "collectionlink"
        @finaldoc += "<a href=\"/search/show/"+attributes["xlink:href"].chomp!(".xml")+"\">"
        when "p"
         @finaldoc += "<p>"
        when "name"
         @finaldoc += "<h3>"
        when "conversionwarning"
         @conversionwarning = 1
        when "title"
         @finaldoc += "<h4>"
        when "normallist"
         @finaldoc += "<ul>"
        when "item"
         @finaldoc += "<li>"
        when "table"
         @finaldoc += "<table"
         attributes.each { |key, value| @finaldoc += " #{key}=\"#{value}\"" }
         @finaldoc += ">"
        when "row"
         @finaldoc += "<tr"
         attributes.each { |key, value| @finaldoc += " #{key}=\"#{value}\"" }
         @finaldoc += ">"
        when "cell"
         @finaldoc += "<td>"
        when "cadre"
         @finaldoc += "<table style=\"border:1px solid grey;\"><tr><td>"

    end

    case name[0,4]
        when "emph"
         @finaldoc += "<em>"
    end
   end

   def text(text)
    if @spaceneeded == 1 && ((text[0,1].to_s.gsub(/(\s|\W|[sS])/, " ") != " ") || text[0,1] == "(")
     @finaldoc += " " 
     @spaceneeded = nil
    end
    @finaldoc += text if @conversionwarning.nil?
    @conversionwarning = nil
   end

   def tag_end(name)
    case name
        when "collectionlink"
         @finaldoc += "</a>"
         @spaceneeded = 1
        when "p"
         @finaldoc += "</p>"
         @spaceneeded = 1
        when "name"
         @finaldoc += "</h3>"
         @spaceneeded = 1
        when "title"
         @finaldoc += "</h4>"
         @spaceneeded = 1
        when "normallist"
         @finaldoc += "</ul>"
        when "item"
         @finaldoc += "</li>"
        when "table"
         @finaldoc += "</table>"
        when "row"
         @finaldoc += "</tr>"
        when "cell"
         @finaldoc += "</td>"
        when "cadre"
         @finaldoc += "</td></tr></table>"
    end
    
    case name[0,4]
        when "emph"
         @finaldoc += "</em>"
         @spaceneeded = 1
    end
   end

   def get_doc
    @finaldoc
   end

end
