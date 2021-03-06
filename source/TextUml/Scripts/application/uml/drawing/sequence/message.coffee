define (require) ->
  Config          = require './config'
  Composite       = require './composite'
  ArrowDirection  = require '../arrowdirection'
  ArrowStyle      = require '../arrowstyle'
  LineStyle       = require '../linestyle'

  SelfInvokingTextMargin = 10
  SelfInvokingLineHeight = 40

  getGap = -> Config.lineSize * 3

  textAttributes =
    fontFamily  : Config.fontFamily
    fontSize    : Config.fontSize
    fill        : Config.foreColor

  class Message extends Composite
    constructor: (@model) -> super

    draw: (context) ->
      arrowStyle = if @model.async
          ArrowStyle.open
        else
          ArrowStyle.close

      lineStyle = if @model.callReturn
          LineStyle.dash
        else
          LineStyle.line

      y = context.getNextShapeStartY()

      senderShape = context.getParticipantShape @model.sender.name
      receiverShape = context.getParticipantShape @model.receiver.name

      gap = getGap()

      if @model.selfInvoking()
        x = senderShape.getLifelineStartPoint().x
        if context.isLast senderShape.model
            arrowDirection = ArrowDirection.right
            x -= gap
          else
            arrowDirection = ArrowDirection.left
            x += gap

        @drawSelfInvoking context
          , arrowDirection
          , arrowStyle
          , lineStyle
          , x
          , y
      else
        if senderShape.getX1() < receiverShape.getX1()
          arrowDirection = ArrowDirection.right
          x1 = senderShape.getLifelineStartPoint().x + gap
          x2 = receiverShape.getLifelineStartPoint().x - gap
        else
          arrowDirection = ArrowDirection.left
          x1 = receiverShape.getLifelineStartPoint().x + gap
          x2 = senderShape.getLifelineStartPoint().x - gap
        @drawRegular context
          , arrowDirection
          , arrowStyle
          , lineStyle
          , x1
          , x2
          , y

      context.addShape @
      @

    drawRegular: (context
      , arrowDirection
      , arrowStyle
      , lineStyle
      , x1
      , x2
      , y
    ) ->
      textSize = context.shapeFactory.textSize context.surface
      , @model.name
      , textAttributes

      width = x2 - x1
      textX = x1 + (width - textSize.width) / 2
      text = context.shapeFactory.text(textX
      , y
      , @model.name
      , textAttributes)
      .draw context.surface

      y += textSize.height + getGap()
      line = context.shapeFactory.horizontalLine(x1
        , y
        , width
        , lineStyle
        , stroke: Config.borderColor)
        .draw context.surface

      x = if arrowDirection is ArrowDirection.left then x1 else x2

      arrowAttributes = stroke: Config.borderColor
      if arrowStyle is ArrowStyle.close
        arrowAttributes.fill = Config.borderColor

      arrow = context.shapeFactory.arrow(x
        , y
        , arrowDirection
        , arrowStyle
        , Config.arrowSize
        , arrowAttributes)
        .draw context.surface

      @children.push text, line, arrow

    drawSelfInvoking: (context
      , arrowDirection
      , arrowStyle
      , lineStyle
      , x
      , y
    ) ->
      textSize = context.shapeFactory.textSize context.surface
      , @model.name
      , textAttributes

      textX = x + SelfInvokingTextMargin / 2
      lineWidth = textSize.width + SelfInvokingTextMargin

      if arrowDirection is ArrowDirection.right
        textX = x - textSize.width - SelfInvokingTextMargin / 2
        lineWidth = -lineWidth

      text = context.shapeFactory.text(textX
        , y
        , @model.name
        , textAttributes)
        .draw context.surface

      y += textSize.height + getGap()
      line1 = context.shapeFactory.horizontalLine(x
        , y
        , lineWidth
        , lineStyle
        , stroke: Config.borderColor)
        .draw context.surface
      line2 = context.shapeFactory.verticalLine(x + lineWidth
        , y
        , SelfInvokingLineHeight
        , lineStyle
        , stroke: Config.borderColor).draw context.surface
      line3 = context.shapeFactory.horizontalLine(x
      , y + SelfInvokingLineHeight
      , lineWidth
      , lineStyle
      , stroke: Config.borderColor)
      .draw context.surface

      arrowAttributes = stroke: Config.borderColor
      if arrowStyle is ArrowStyle.close
        arrowAttributes.fill = Config.borderColor 

      arrow = context.shapeFactory.arrow(x
        , y + SelfInvokingLineHeight
        , arrowDirection
        , arrowStyle
        , Config.arrowSize
        , arrowAttributes)
        .draw context.surface

      @children.push text, line1, line2, line3, arrow