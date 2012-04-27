#
# CSS Formatter
#
# Tidys up the formatting on a CSS file. This will generate uniform spacing,
# intenting and general formatting throughout your CSS file.
#
# @author Chris Worfolk
#
# @todo Comment blocks lose their first spacing character
#

# include libraries
require "pp"

# configuration
OUTPUT_FORMAT = :default

# command line arguments
if ARGV.count == 0
	puts "USAGE: cssFormatter.rb <input file> (<output file>)"
	exit 0
end

# calculate output filename
outputFile = (ARGV[1]) ? ARGV[1] : "formatted.css"

# read in existing file
file = File.open(ARGV[0])

# html tags
htmlTags = [
	"a",
	"br",
	"dd",
	"div",
	"dl",
	"dt",
	"fieldset",
	"form",
	"h1",
	"h2",
	"h3",
	"h4",
	"h5",
	"h6",
	"img",
	"input",
	"label",
	"li",
	"p",
	"select",
	"span",
	"table",
	"td",
	"tr",
	"ul",
]

# begin output for formatted file
contents = []
inDeclaration = false
inCommentBlock = false
inSubBrackets = false
addLineBreak = false

# read through each line
file.each { |line|

	# first off, strip the line
	line = line.strip
	
	# check for start of comment
	if line[0,2] == "/*"
		inCommentBlock = true
	end
	
	# if line is not a comment
	if inCommentBlock === false
	
		# always use single quotes
		line = line.gsub('"', "'")
		
		if inDeclaration === false
		
			# add a space before the declaration
			if line.include?(" {") === false
				line = line.gsub("{", " {")
			end
			
			# add spacing after commas
			line = line.gsub(/,([^ ])/, ", \\1")
			
			# make sure HTML tags are lowercase
			htmlTags.each { |tag|
				line = line.gsub(/#{Regexp.escape(tag.upcase)}([^a-z0-9])/i, tag+"\\1")
			}
			
			# does it finish on this line?
			if line.include?("{")
				inDeclaration = true
			end
		
		else
		
			# indentation
			if inSubBrackets && line != ");"
				indent = "\t\t"
			else
				indent = "\t"
			end
			
			# correct indentation
			if (line != "}")
				line = indent+line
			end
			
			# add spacing after colon
			if line.include?(": ") === false
				line = line.gsub(":", ": ")
			end
			
			# ensure URLs have quote marks
			line = line.gsub(/url\(([^\)\'\"]+)\)/, "url('\\1')")
			
			# do we have sub-clauses?
			if line[-1, 1] == "("
				inSubBrackets = true
			end
			
			if line[-2, 2] == ");"
				inSubBrackets = false
			end
		
		end
		
		# is declaration finished?
		if line.include?("}")
			addLineBreak = true
			inDeclaration = false
		end
	
	end
	
	# check for end of comment
	if line.include?("*/")
		if inCommentBlock
			addLineBreak = true
		end
		inCommentBlock = false
	end
	
	# add line to output
	if (line.strip != "")
		contents << line
	end
	
	# add extra line break if required
	if addLineBreak
		contents << ""
		addLineBreak = false
	end

}

# remove the last blank line
contents.pop

# add line endings
formattedContents = []

contents.each { |line|
	case OUTPUT_FORMAT
		when :compact
			if line == "}"
				newLine = line+"\n"
			else
				newLine = line.strip+" "
			end
		else
			newLine = line+"\n"
		end
		formattedContents << newLine
}

# outputting for debugging
#contents.each { |line|
#	puts line
#}
#pp(contents)

# write the file
File.open(outputFile, 'w') {|f| f.write(formattedContents) }
