require_relative 'post'
require_relative 'user'


class Comment<ActiveRecord::Base
  belongs_to :post
  belongs_to :user


    def print
  	str1 = (CGI.escapeHTML self.content).to_s
    str2 = str1.dup
    
    str1.scan(/\*\*.+\*\*/) { |match| str2[match]="<b>"+match[2..-3]+"</b>"}
    str1 = str2.dup

  	str1.scan(/\*.+\*/) { |match| str2[match]="<i>"+match[1..-2]+"</i>"}
    str1 = str2.dup

    str1.scan(/(?<nameUrl>\[.*\])(?<link>\(.*\))/) do |match| 
      link = "\"https://" + match[1][1..-2] + "\""
      linkText = match[0][1..-2]
      str2[match[0]+match[1]]="<a href=" + link + ">" + linkText + "</a>"
    end

    str1 = str2.dup
    str1.scan(/(?<times>^\#{1,6})(?<row>.*)/) do |match|
      size = match[0].length.to_s
      str2[match[0]+match[1]]="<h" + size + ">" + match[1] + "</h" + size + ">"
    end
  	# (CGI.escapeHTML self.theme).to_s.scan(/_\w+_/) { |match| answer[match]="<i>"+match[1..-2]+"</i>"}
  	# (CGI.escapeHTML self.theme).to_s.scan(/__\w+__/) { |match| answer[match]="<b>"+match[2..-3]+"</b>"}
  	str2
  end
end