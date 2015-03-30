module Jekyll
  class BoxStartTag < Liquid::Block

    def initialize(tag_name, title, tokens)
      super
      @title = title.strip
    end

    def render(context)
      output = context.registers[:site]
        .getConverterImpl(::Jekyll::Converters::Markdown)
        .convert(super(context))

      title = context[@title] || @title

      toReturn = '<div class="box">'
      if !(title.empty?)
        toReturn << '<div class="box-header">' + title + '</div>'
      end
      toReturn << '<div class="box-content">' + output + '</div></div>'

      toReturn
    end
  end
end

Liquid::Template.register_tag('box', Jekyll::BoxStartTag)
