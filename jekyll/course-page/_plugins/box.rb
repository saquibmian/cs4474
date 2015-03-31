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
      date = data['date']
      due = data['due']
      url = data['url'] || ""
        
      toReturn = '<div class="box">'
      
      if !(title.empty?)
        toReturn << '<a href="' + url + '" class="box-header">'
        toReturn << '<div class="box-title">' + title + '</div>'
        
        if !(date.nil?) || !(due.nil?)
          toReturn << '<div class="flex-fill"></div><table class="date-info"><tbody>'

          if !(date.nil?)
            toReturn << '<tr><td class="date-title">Posted:</td><td class="date">' + date.strftime(@time_format) + '</td></tr>'
          end
          if !(due.nil?)
            toReturn << '<tr><td class="date-title">Due:</td><td class="date">' + due.strftime(@time_format) + '</td></tr>'
          end

          toReturn << '</tbody></table>'
        end

        toReturn << '</a>'
      end
      toReturn << '<div class="box-content">' + output + '</div></div>'

      toReturn
    end
  end
end

Liquid::Template.register_tag('box', Jekyll::BoxStartTag)
