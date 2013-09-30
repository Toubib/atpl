#       
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#       Copyright Vincent Reydet

require 'fileutils'

class Template

  TAG_SNIPPET_PRE='#{snippet:'
  TAG_SNIPPET_POST='}'
  TAG_CONFIG_PRE='#{'
  TAG_CONFIG_POST='}'
  TAG_SET_CONFIG='#setconfig:'


  def initialize(snippetDir="snippet")
    @snippetDir=snippetDir
    @snippets={}
    @localConfig={}
  end
  
  def setServerConfig(serverConfig)
    @serverConfig=serverConfig
  end

  def process(filename)
    @fileName=filename
    fileContent=readInputFile #get file content
    readlocalConfig(fileContent) #read input file content variables
    readSnippetFiles #read snippet files

    #replace snippets
    @snippets.each { |k,v|
      fileContent.each { |line|
        line.gsub!(TAG_SNIPPET_PRE+k+TAG_SNIPPET_POST,v)
      }
    }

    #replace server variables
    @serverConfig.each { |k,v|
      fileContent.each { |line|
        line.gsub!(TAG_CONFIG_PRE+k+TAG_CONFIG_POST,v)
      }
    }

    #replace local variables
    @localConfig.each { |k,v|
      fileContent.each { |line|
        line.gsub!(TAG_CONFIG_PRE+k+TAG_CONFIG_POST,v)
      }
    }

    #return new file content
    fileContent.to_s
  end

  private 
  def readSnippetFiles
    Dir.foreach(@snippetDir){ |f|
      next if f=="." or f==".." or !File.file?(@snippetDir+'/'+f)
      open (@snippetDir+'/'+f) { |openedFile|
        @snippets[f]=openedFile.read
      }
    }
  end
  def readInputFile
    open (@fileName) { |f|
      f.readlines
    }
  end
  def readlocalConfig(file)
    linesToDelete=[]
    file.each { |line| 
      next if line =~ /^(?!#setconfig:)/ #match only var lines TODO replace by TAG_SET_CONFIG
      line.gsub!(TAG_SET_CONFIG,'') #remove the tag
      varArray=line.split('=') #read the var
      @localConfig[varArray[0]]=varArray[1].strip #put the var on the table
      linesToDelete<<line; #mark line to delete
    }
    #remove var lines
    linesToDelete.each{ |l|
      file.delete(l)
    }
  end

end
