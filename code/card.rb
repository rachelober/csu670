# !/arch/unix/bin/ruby

# card.rb
# First included in Project 3
# This file includes all classes that are used in creating Cards
# Dependant on:
# + Alliance
# + Category
# + Image

# Required files
require 'code/alliance.rb'
require 'code/category.rb'
require 'code/image.rb'

# This class creates cards that will be played in the game.
# There are three different cards types:
# * Aircraft
# * Keepem
# * Victory
class Card
  include Comparable
  include DesignByContract
  attr_reader :image

  # new : Image -> Card
  # 
  # Create a new Object of type Card.
  # All Cards require an Image file_name.
  def initialize(image)
    create(image)
  end
    
  pre(:create, "Input must be of class Image") {|image| image.instance_of?(Image)}
  # create : Image -> Card
  #
  # Create a new Object of type Card.
  # All Cards require an Image file_name.
  def create(image)
    @image = image    # Image
  end

  # Super method for comparing different cards.
  def cards_have_same_name?(card)
  end

  # Super method for assigning a value to a card for sorting purposes.
  def card_value
  end

  # card_less_than? : Card Card -> Boolean
  #
  # Evaluates if This is less than Card.
  # If This Card is less than given the Card, returns true.
  # Else, returns false.
  # This depends on the <=> method found in the subclasses.
  def card_less_than?(card)
    self < card
  end

  # aircraft? : Card -> Boolean
  #
  # Is this Card an Aircraft?
  def aircraft?
    false
  end

  # wildcard? : Card -> Boolean
  #
  # Is this Card a WildCard?
  def wildcard?
    false
  end

  # keepem? : Card -> Boolean
  #
  # Is this Card a Keepem?
  def keepem?
    false
  end

  # victory? : Card -> Boolean
  #
  # Is this Card a Victory?
  def victory?
    false
  end

  # to_s : Card -> String
  #
  # Create a readable string from this Card.
  def to_s
  end
  
  # Card.xml_to_card : Document -> Card
  #
  # Converts the given XML to a Card Object.
  def Card.xml_to_card(card_xml)
    file = File.new('aircrafts/index.xml')
    doc = Document.new file
    root = card_xml.root
    
    if(root.name == 'AIRCRAFT')
      # Gets information from the xml given from standardout
      name = root.attributes['NAME'].to_s
      tag = root.attributes['TAG'].to_i
      # Gathers information from index.xml to create new Aircraft
      from_file = XPath.match(doc, "//aircraft[@name=\"#{name}\"]")
      nation = from_file[0].attributes["nation"].to_s
      category = from_file[0].attributes["category"].to_s
      image = from_file[0].attributes["image"].to_s
      # Make new objects
      if(category == "fighter")
        category = Fighter.new
      elsif(category == "bomber")
        category = Bomber.new
      end
      if(nation == "axis")
        nation = Axis.new
      elsif(nation == "allies")
        nation = Allies.new
      end
      image = Image.new(image)
      # Create a new Aircraft Card
      return Aircraft.new(image, name, nation, category, tag)
    elsif(root.name == "KEEPEM")
      # Gets information from the xml given from standardout
      tag = root.attributes['TAG'].to_i
      image = Image.new("keepem.gif")
      # Create new Keepem Card
      return Keepem.new(image, tag)
    else (root.name == "VICTORY")
      image = Image.new("victory.gif")
      # Create a new Victory Card
      return Victory.new(image)
    end
  end
end

# The Aircraft class holds all information about Aircraft cards.
# It inherits from the Card class and inherits the image attribute.
# Aircrafts include a name, an Alliance, a Category and a tag.
# The Alliance can either be Axis or Allies, and the Category can either be
# Fighter or Bomber. The tag can be 1, 2, or 3 and represents the different
# "sides" of the Aircraft.
class Aircraft < Card
  include DesignByContract
  attr_reader :name, :a, :forb, :tag

  # initialize : Image String Alliance Category Integer -> Aircraft
  #
  # Create a new Card of type Aircraft.
  # All Aircraft Cards require an image of type Image, name, a of type 
  # Alliance, and forb of type Category.
  # Image is inherited from the Card class.
  def initialize(image, name, a, forb, tag)
    create(image, name, a, forb, tag)
  end
  
  pre("image needs to be an Image.") {|image, name, a, forb, tag| image.instance_of?(Image)}
  pre("name needs to be a String.") {|image, name, a, forb, tag| name.instance_of?(String)}
  pre("a needs to be an Alliance.") {|image, name, a, forb, tag| a.kind_of?(Alliance)}
  pre("forb needs to be a Category.") {|image, name, a, forb, tag| forb.kind_of?(Category)}
  pre("tag needs to be an Integer.") {|image, name, a, forb, tag| tag.kind_of?(Integer)}
  # create : Image -> Card
  #
  # Create a new Object of type Card.
  # All Cards require an Image file_name.
  def create(image, name, a, forb, tag)
    super(image)  # Image
    @name = name  # String
    @a = a        # Alliance
    @forb = forb  # Category
    @tag = tag    # Integer
  end
  
  # cards_have_same_name? : Aircraft Card -> Boolean
  #
  # Takes a Card and checks to see if it has a name attribute.
  # If it has a name property, then checks to see if the this has the same
  # name as the Card. Otherwise, it returns false because the name 
  # attributes can't be compared.
  pre("Input must be of class Card.") {|card| card.kind_of?(Card)}
  def cards_have_same_name?(card)
    if(card.respond_to?("name"))
      self.name == card.name
    else
      false
    end
  end

  # card_value : Aircraft -> Integer
  #
  # Gets the Aircraft's value from the Category class.
  post{|i| i.kind_of?(Integer) && i >= 0}
  def card_value
    @forb.value
  end

  # aircraft? : Card -> Boolean
  #
  # Is this Card an Aircraft?
  def aircraft?
    true
  end

  # equal? : Aircraft Card -> Boolean
  #
  # Are these two cards equal?
  pre("Input must be of class Card.") {|card| card.kind_of?(Card)}
  def equal?(card)
    self == card
  end
  
  # to_s : Card -> String
  #
  # Create a readable string from this Card.
  def to_s
    'Aircraft Card ' + @name.to_s + ' Tag:' + @tag.to_s + ' ' + @a.to_s + ' ' + @forb.to_s
  end
  
  # <=> : Aircraft Card -> (-1, 0 or +1)
  #
  # This method helps us to compare Aircraft cards to other cards.
  # If the other Card is an Aircraft Card with the same name, it compares
  # by the "tag" attribute. If they are both Aircraft cards but do not
  # share the same name, they are compared alphabetically. Otherwise,
  # the cards are compared by their card values.
  pre("Input must be of class Card.") {|card| card.kind_of?(Card)}
  def <=>(card)
    if cards_have_same_name?(card)
      @tag <=> card.tag
    elsif card.instance_of?(Aircraft)
      @name.downcase <=> card.name.downcase
    else
      card_value <=> card.card_value
    end
  end
  
  # card_to_xml : Aircraft -> Document
  #
  # Converts Aircraft Card into a XML String.
  def card_to_xml
    aircraft = Document.new
    aircraft.add_element "AIRCRAFT", {"NAME"=>"#{@name}", "TAG"=>"#{@tag}"}
  end
end

# A WildCard can be either a Victory or a Keepem Card.
# This class is a parent to both Victory and Keepem.
class WildCard < Card
  include DesignByContract
  
  # initialize : Image -> WildCard
  #
  # Create a new Card of type Wildcard.
  # All WildCards require a file_name.
  # Image is inherited from the Card class.
  def initialize(image)
    super(image)    # Image
  end

  # wildcard? : Card -> Boolean
  #
  # Is this Card a WildCard?
  def wildcard?
    true
  end
end

# There is only one Victory Card for the Deck. The Victory Card includes an Image
# and has a card value of 0.
class Victory < WildCard
  include DesignByContract
  
  # initialize : Image -> Victory
  #
  # Create a new WildCard of type Victory
  # All Victory WildCards require a file_name
  # Image is inherited from the Card class
  def initialize(image)
    super(image)    # Image
  end
   
  # cards_have_same_name? : Victory Card -> Boolean
  #
  # Takes a Card and checks to see if its type is Victory.
  def cards_have_same_name?(card)
    card.instance_of?(Victory)
  end

  # card_value : Victory -> Integer
  #
  # Victory WildCards are given the card value of 0, worth no points.
  def card_value
    return 0
  end

  # victory? : Card -> Boolean
  #
  # Is this Card a Victory?
  def victory?
    true
  end
  
  # equal? : Victory Card -> Boolean
  #
  # Are these two cards equal?
  pre("Input must be of class Card.") {|card| card.kind_of?(Card)}
  def equal?(card)
    self == card
  end
  
  # to_s : Card -> String
  #
  # Create a readable string from this Card
  def to_s
    'Victory Card'
  end
  
  # <=> : Victory Card -> (-1, 0 or +1)
  #
  # This is the method that helps us compare the Victory Card to other cards.
  # We want to order hands based upon the value of our cards, therefore Victory
  # cards are ordered as the first. In this method we organize it so that Victory is always the first.
  pre("Input must be of class Card.") {|card| card.kind_of?(Card)}
  def <=>(card)
    if card.instance_of?(Aircraft)
      return -1
    elsif card.instance_of?(Keepem)
      return -1
    else
      return 0
    end
  end
  
  # card_to_xml : Victory -> Document
  #
  # Converts Victory Card into a XML String.
  def card_to_xml
    victory = Document.new
    victory.add_element "VICTORY"
  end
end

# There are up to 6 Keepem cards in the Deck. Each Keepem Card has an index to keep
# track of them. The Keepem cards inherit the Image attribute from the Card class.
class Keepem < WildCard
  include DesignByContract
  attr_reader :index

  # initialize : Image Integer -> Keepem
  #
  # Create a new WildCard of type Keepem.
  # All Keepem WildCards require a file_name and index.
  # Image is inherited from the Card class.
  def initialize(image, index)
    super(image)      # Image
    @index = index    # Integer
  end
   
  # cards_have_same_name? Keepem Card -> Boolean
  #
  # Takes a Card and checks to see if its type is Keepem.
  pre("Input must be of class Card.") {|card| card.kind_of?(Card)}
  def cards_have_same_name?(card)
    card.instance_of?(Keepem)
  end

  # card_value : Keepem -> Integer
  #
  # Keepem WildCards are given the card value of 0, worth no points.
  def card_value
    return 0
  end

  # max : Keepem -> Integer
  #
  # Returns the max amount of Keepems allowed to be made in a Deck.
  def Keepem.max
    return 6
  end

  # keepem? : Card -> Boolean
  #
  # Is this Card a Keepem?
  def keepem?
    true
  end

  # equal? : Keepem Card -> Boolean
  #
  # Are these two cards equal?
  pre("Input must be of class Card.") {|card| card.kind_of?(Card)}
  def equal?(card)
    self == card
  end

  # to_s : Card -> String
  #
  # Create a readable string from this Card
  def to_s
    'Keepem Card ' + 'Tag:' + @index.to_s
  end
  
  # <=> : Keepem Card -> (-1, 0 or +1)
  #
  # This method helps us to order the cards in our Hand. Generally we want Keepem
  # cards to follow the Victory Card (if it exists.) Therefore, if the Victory Card exists,
  # the Keepem Card is placed after. If it compares against another Victory Card, 
  # they are compared on their index number. If it compares against an Aircraft Card, the Keepem
  # Card always preceeds an Aircraft Card.
  pre("Input must be of class Card.") {|card| card.kind_of?(Card)}
  def <=>(card)
    if cards_have_same_name?(card)
      @index <=> card.index
    elsif card.instance_of?(Aircraft)
      return -1
    elsif card.instance_of?(Victory)
      return +1
    end
  end
  
  # card_to_xml : Keepem -> Document
  #
  # Converts Keepem Card into a XML String.
  def card_to_xml
    keepem = Document.new
    keepem.add_element "KEEPEM", {"TAG"=>"#{@index}"}
  end
end
