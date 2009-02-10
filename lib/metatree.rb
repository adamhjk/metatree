#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'metatree/node'

class Metatree

  attr_accessor :tree
          
  def initialize(content=nil)
    @root = Metatree::Node.new('/')
  end
  
  def node(path)
    return @root if path == '/'
    
    parts = path.split('/')
    parts.shift
    
    branch = @root
    
    result = nil
    last_part = parts.length - 1
    parts.each_index do |i|
      if branch.has_child?(parts[i])
        branch = branch.child(parts[i])
      else
        nl = Metatree::Node.new(parts[i])
        branch.add_child(nl)
        branch = nl
      end
      result = branch if i == last_part      
    end
    result
  end
    
  def has_node?(path)
    result = false
    return true if path == '/'
    
    parts = path.split('/')
    parts.shift
    branch = @root
    last_part = parts.length - 1
    
    parts.each_index do |i|
      if branch.has_child?(parts[i])
        branch = branch.child(parts[i])
      else
        return false
      end
      result = true if i == last_part
    end
    
    result
  end
  
  def get(path)
    if path == "/"
      return node('/').metadata
    end
        
    parts = path.split('/')
    parts.shift
    branch = @root

    md = Metatree::Node.new('results')
    
    md.merge(node('/'))
    
    last_part = parts.length - 1
    parts.each_index do |i|
      if branch.has_child?(parts[i])
        branch = branch.child(parts[i])
      else
        raise "Missing node at #{parts[i]}"
      end  

      md.merge(branch)

      if i == last_part        
        md.local_data(branch.local_data)
      end    
    end
  
    md.metadata
  end
  
end
