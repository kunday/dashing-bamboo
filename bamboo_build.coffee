class Dashing.BambooBuild extends Dashing.Widget

  @accessor 'value', Dashing.AnimatedValue
  @accessor 'bgColor', ->
    if @get('state') == "Success"
      "#96bf48"
    else if @get('state') == "Failed"
      "#D26771"
    else if @get('state') == "PREBUILD"
      "#ff9618"
    else
      "#999"

  constructor: ->
    super
    @observe 'value', (value) ->
      $(@node).find(".jenkins-build").val(value).trigger('change')
      @refreshLastRun()


  refreshLastRun: =>
    if timestamp = @get('timestamp')
      lastRun = moment(timestamp).fromNow();
      @set('lastRunDateTime', "#{lastRun}")

  ready: ->
    meter = $(@node).find(".jenkins-build")
    $(@node).fadeOut().css('background-color',@get('bgColor')).fadeIn()
    meter.attr("data-bgcolor", meter.css("background-color"))
    meter.attr("data-fgcolor", meter.css("color"))
    meter.knob()

  onData: (data) ->
    console.log(data)
    if data.currentResult isnt data.lastResult
      $(@node).fadeOut().css('background-color',@get('bgColor')).fadeIn()
