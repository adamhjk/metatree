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

class Metatree
  class Node
    
    attr_accessor :name, :children
    
    def initialize(name)
      @name = name
      @local_data = Hash.new
      @inherit_data = Hash.new
      @stop_inheritance = Array.new
      @children = Hash.new
    end
    
    def to_s
      @name
    end
    
    def local_data(data=nil)
      if data
        data.each do |key, value|
          @local_data[key] = value
        end
      else
        @local_data
      end
    end
    
    def inherit_data(data=nil)
      if data
        data.each do |key, value|
          @inherit_data[key] = value
        end
      else
        @inherit_data
      end
    end
    
    def can_inherit?(key)
      if @stop_inheritance.include?(key)
        false
      else
        true
      end
    end
    
    def get(key)
      if @local_data.has_key?(key)
        @local_data[key]
      elsif @inherit_data.has_key?(key)
        @inherit_data[key]
      else
        nil
      end
    end
    
    def stop_inheritance(key=nil)
      if key
        @stop_inheritance << key if can_inherit?(key)
      else
        @stop_inheritance
      end
    end
    
    def metadata
      md = Hash.new
      @local_data.each do |key, value|
        md[key] = value
      end
      @inherit_data.each do |key, value|
        md[key] = value unless md.has_key?(key)
      end
      md
    end
    
    def add_child(mt)
      raise ArgumentError, "Must be a Metatree::Node" unless mt.kind_of?(Metatree::Node)
      @children[mt.to_s] = mt
    end
    
    def child(name)
      @children[name]
    end
    
    def has_child?(name)
      @children.has_key?(name)
    end
    
    def remove_child(name)
      @children.remove(name.to_s)
    end
    
    def merge(node)
      inherit_data(node.inherit_data)
    
      node.stop_inheritance.each do |key|
        if inherit_data.has_key?(key)
          inherit_data.delete(key)
        end
      end
      
      true
    end
    
  end
end
