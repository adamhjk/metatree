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

require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

describe Metatree do
  
  before(:each) do
    @tree = Metatree.new
  end
  
  describe "initialize" do
    it "should return a Metatree object" do
      @tree.should be_a_kind_of(Metatree)
    end
    
    it "should have a / leaf" do
      @tree.node('/').to_s.should eql('/')
    end
  end
  
  describe "leaf" do
    it "should return a leaf" do
      @tree.node('/foo').should be_a_kind_of(Metatree::Node)
    end
    
    it "should create intermediate leaves" do
      @tree.node("/foo/bar/baz").should be_a_kind_of(Metatree::Node)
      @tree.has_node?('/foo').should eql(true)      
      @tree.has_node?('/foo/bar').should eql(true)      
      @tree.has_node?('/foo/bar/baz').should eql(true)
    end
  end
  
  describe "has_node?" do
    it "should return true if a leaf exists" do
      @tree.node('/foo/bar')
      @tree.has_node?('/foo/bar').should eql(true)
    end
    
    it "should return false if a leaf does not exist" do
      @tree.has_node?('/snozzle/monkey').should eql(false)
    end
  end
  
  describe "get" do
    it "should inherit metadata for a path from its parents" do
      @tree.node("/").inherit_data(:snack => "tasty")
      @tree.node("/foo")
      @tree.get("/foo").should == { :snack => "tasty" }
    end
    
    it "should stop inheriting metadata if we are told to" do
      @tree.node("/").inherit_data(:snack => "tasty")
      @tree.node("/foo").stop_inheritance(:snack)
      @tree.node("/foo/bar")
      @tree.get("/foo/bar").should == { }
    end
    
    it "should prefer local metadata to inherited" do
      @tree.node("/").inherit_data(:snack => "tasty")
      @tree.node("/foo").local_data(:snack => "icky")
      @tree.get("/foo").should == { :snack => "icky" }
    end
    
    it "should return the full metadata for a path" do
      @tree.node("/").inherit_data(:snack => "tasty")
      @tree.node("/vegetarian").inherit_data(:wet => 'blanket')
      @tree.node("/vegetarian/band").inherit_data(:brick_wall => 'foo')  
      @tree.node("/vegetarian/band/one").local_data(:something => 'to eat')
      @tree.node("/vegetarian/band").stop_inheritance(:snack)
      @tree.get("/vegetarian/band/one").should == {
        :wet => "blanket",
        :brick_wall => "foo",
        :something => 'to eat'
      }
    end
  end
  
end

