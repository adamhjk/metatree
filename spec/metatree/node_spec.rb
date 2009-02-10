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

require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))

describe Metatree::Node do
  before(:each) do
    @leaf = Metatree::Node.new("tulip")
  end
  
  describe "initialize" do
    it "should return a Metatree::Node object" do
      @leaf.should be_a_kind_of(Metatree::Node)
    end
  
    it "should set the name of the leaf" do
      @leaf.name.should eql("tulip")
    end
  end
  
  describe "to_s" do
    it "should return the leaf name" do
      @leaf.to_s.should eql("tulip")
    end
  end
  
  describe "get" do    
    it "should return the local_data metadata first" do
      @leaf.local_data(:beer => "is good")
      @leaf.get(:beer).should eql("is good")
    end
    
    it "should return the inherited/inheritable metadata" do
      @leaf.inherit_data(:beer => "is like wine, only more beer-like")
      @leaf.get(:beer).should eql("is like wine, only more beer-like")
    end
    
    it "should prefer local_data to inherit metadata" do
      @leaf.local_data(:beer => "is good")
      @leaf.inherit_data(:beer => "is like wine, only more beer-like")
      @leaf.get(:beer).should eql("is good")
    end
  end
  
  describe "local_data" do
    it "should set a local_data metadata key" do
      @leaf.local_data(:color => [ :red, :yellow ])
      @leaf.get(:color).should eql([ :red, :yellow ])
    end
    
    it "should return the local metadata if it has no argument" do
      @leaf.local_data(:color => [ :red, :blue ])
      @leaf.local_data.should == {:color => [ :red, :blue ]}
    end
  end
  
  describe "inherit_data" do
    it "should set an inherited metadata key" do
      @leaf.inherit_data(:color => [ :red, :blue ])
      @leaf.get(:color).should eql([ :red, :blue ])
    end
    
    it "should return the inherited metadata if it has no argument" do
      @leaf.inherit_data(:color => [ :red, :blue ])
      @leaf.inherit_data.should == {:color => [ :red, :blue ]}
    end
  end
  
  describe "can_inherit?" do
    it "should return true if we allow inheritance for a key" do
      @leaf.can_inherit?(:anything).should eql(true)
    end
    
    it "should return false if we stop inheritance for a key" do
      @leaf.stop_inheritance(:color_blindness)
      @leaf.can_inherit?(:color_blindness).should eql(false)
    end
  end
  
  describe "stop_inheritance" do
    it "should store the metadata key to stop" do
      @leaf.stop_inheritance(:color)
      @leaf.can_inherit?(:color)
    end
    
    it "should return the stop_inheritance hash with no argument" do
      @leaf.stop_inheritance(:color)
      @leaf.stop_inheritance.should == [ :color ]
    end
  end
  
  describe "metadata" do
    it "should set local metadata values" do
      @leaf.local_data(:color => :black)
      @leaf.local_data(:monkey => :back)
      @leaf.metadata.should have_key(:color)
    end
    
    it "should set inherited metadata values" do
      @leaf.inherit_data(:color => :black)
      @leaf.inherit_data(:monkey => :back)
      @leaf.metadata.should have_key(:color)
    end
    
    it "should prefer local metadata over inherited" do
      @leaf.local_data(:color => :black)
      @leaf.inherit_data(:color => :blue)
      @leaf.metadata[:color].should eql(:black)
    end
  end
end
