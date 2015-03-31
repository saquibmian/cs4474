module Jekyll
  class BoxStartTag < Liquid::Block


    def initialize(tag_name, input, tokens)
      super
      @input = input.strip
      @time_format = "%b %-d, %Y at %l:%M %p"
    end
  
    def lookup(context, name)
      lookup = context
      name.split(".").each { |value| lookup = lookup[value] }
      lookup
    end

    def get_data(context, property)
      data = context[property] || property
      if data.is_a? String
        data = { 'title' => context[property] || property }
      end

      data
    end

    def render(context)
      output = context.registers[:site]
        .getConverterImpl(::Jekyll::Converters::Markdown)
        .convert(super(context))

      data = get_data(context, @input)

      title = data['title']
        
      toReturn = '<div class="box">'
      
      if !(title.empty?)
        toReturn << '<div class="box-header">'
        toReturn << '<div class="box-title">' + title + '</a></div>'
        
        toReturn << '</div>'
      end
      toReturn << '<div class="box-content">' + output + '</div></div>'

      toReturn
    end
  end
end

Liquid::Template.register_tag('box', Jekyll::BoxStartTag)
