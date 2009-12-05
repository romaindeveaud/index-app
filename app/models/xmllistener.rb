require 'rexml/document'
require 'rexml/streamlistener'
include REXML

class XMLlistener
   include StreamListener

   def text
   end

end
