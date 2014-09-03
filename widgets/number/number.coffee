class Dashing.Number extends Dashing.Widget
  @accessor 'current', Dashing.AnimatedValue

  @accessor 'difference', ->
    if @get('last')
      last = parseInt(@get('last'))
      current = parseInt(@get('current'))
      if last != 0
        diff = Math.abs(Math.round((current - last) / last * 100))
        "#{diff}%"
    else
      ""

  @accessor 'arrow', ->
    if @get('last')
      if parseInt(@get('current')) > parseInt(@get('last')) then 'icon-arrow-up' else 'icon-arrow-down'


  ready: ->
    @changeColor()

  changeColor: ->
    id = $(@get('node')).first().attr('id')

    switch id
      when 'spree-1'
        $(@get('node')).find('h2').css('color', 'white')
        $(@get('node')).find('h1').css('color', 'white')
      when 'spree-2'
        $(@get('node')).find('h2').css('color', 'black')
        $(@get('node')).find('h1').css('color', 'black')
      when 'spree-3'
        $(@get('node')).find('h2').css('color', 'black')
        $(@get('node')).find('h1').css('color', 'black')
      when 'spree-4'
        $(@get('node')).find('h2').css('color', 'black')
        $(@get('node')).find('h1').css('color', 'black')
      when 'spree-5'
        $(@get('node')).find('h2').css('color', 'black')
        $(@get('node')).find('h1').css('color', 'black')



  onData: (data) ->

    if data.status
      # clear existing "status-*" classes
      $(@get('node')).attr 'class', (i,c) ->
        c.replace /\bstatus-\S+/g, ''
      # add new class
      $(@get('node')).addClass "status-#{data.status}"
