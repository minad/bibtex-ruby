#--
# BibTeX-Ruby
# Copyright (C) 2010  Sylvester Keil <sylvester.keil.or.at>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++

module BibTeX
  #
  # Represents a regular BibTeX entry.
  #
  class Entry < Element
    attr_reader :key, :type, :values
   
    # Hash containing the required fields of the standard entry types
    @@RequiredFields = Hash.new([])
    @@RequiredFields.merge!({
      :article => [:author,:title,:journal,:year],
      :book => [[:author,:editor],:title,:publisher,:year],
      :booklet => [:title],
      :conference => [:author,:title,:booktitle,:year],
      :inbook => [[:author,:editor],:title,[:chapter,:pages],:publisher,:year],
      :incollection => [:author,:title,:booktitle,:publisher,:year],
      :inproceedings => [:author,:title,:booktitle,:year],
      :manual => [:title],
      :mastersthesis => [:author,:title,:school,:year],
      :misc => [],
      :phdthesis => [:author,:title,:school,:year],
      :proceedings => [:title,:year],
      :techreport => [:author,:title,:institution,:year],
      :unpublished => [:author,:title,:note]
    })

    def initialize(type, key)
      self.key = key
      self.type = type
      @values = {}
    end

    def key=(key)
      raise(ArgumentError, "BibTeX::Entry key must be of type String; was: #{key.class.name}.") unless key.kind_of?(::String)
      @key = key
    end

    def type=(type)
      raise(ArgumentError, "BibTeX::Entry type must be of type Symbol; was: #{type.class.name}.") unless type.kind_of?(Symbol)
      @type = type
    end
    
    def <<(value)
      @values = @values.merge(value)
      self
    end

    def empty?
      @values.empty?
    end

    # Returns false if the entry is one of the standard entry types and does not have
    # definitions of all the required fields for that type.
    def valid?
      !@@RequiredFields[@type].map { |f| f.kind_of?(Array) ? !(f & @values.keys).empty? : !@values[f].nil? }.include?(false)
    end

    def content
      "@#{type}{#{key},\n" + values.keys.map { |k| "#{k} = #{StringReplacement.to_s(@values[k])}" }.join(",\n") + "\n}"
    end
  end
end
