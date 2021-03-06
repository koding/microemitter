class EventEmitter
  'use strict'

  idKey = 'ಠ_ಠ'
  
  @listeners = {}
  @targets = {}
  
  @off =(listenerId)->
    ###
    Note: @off, but no symmetrical "@on".  This is by design.
      One shouldn't add event listeners directly.  These static
      collections are maintained so that the listeners may be
      garbage collected and removed from the emitter's record.
      To that end, @off provides a handy interface.
    ###
    delete @listeners[listenerId]
    delete @targets[listenerId]
    return this
  
  defineProperty = Object.defineProperty ||
    (obj, prop, {value})-> obj[prop] = value

  createId = do -> counter = 0; -> counter++

  mixin =(obj)->
    prot = EventEmitter::
    obj[prop] = prot[prop] for prop of prot

  init =(obj)->
    unless idKey of obj
      defineProperty( obj, idKey,
        value: "#{Math.round Math.random() * 1e9}"
      )
    unless '_events' of obj
      defineProperty( obj, '_events'
        value         : {}
        # writable      : yes
      )

  constructor:(obj)-> if obj? then mixin obj

  on:(evt, listener)->
    throw new Error 'Listener is required!'  unless listener?

    init this
    
    @emit 'newListener', evt, listener

    listeners = @_events[evt] or= {}
    if @[idKey] of listener
      lid = listener[@[idKey]]
    else
      lid = do createId
      defineProperty( listener, @[idKey],
        value: lid
      )
    
    EventEmitter.listeners[lid] = \
    listeners[lid] = listener
    
    EventEmitter.targets[lid] = this
    
    return this

  once:(evt, listener)->
    wrappedListener = (rest...)=>
      @off evt, wrappedListener
      listener.apply @, rest
    @on evt, wrappedListener

  off:(evt, listener)->
    init this
    switch arguments.length
      when 0 then delete @_events[key]  for own key of @_events
      when 1 then @_events[evt] = {}
      else
        listeners = @_events[evt]
        listenerId = listener[@[idKey]]
        delete listeners[listenerId]  if listeners?
        EventEmitter.off listenerId
    return this

  emit:(evt, rest...)->
    init this
    listeners = @_events[evt] ? []
    listener.call @, rest... for own id, listener of listeners
    if evt is 'error' and listeners.length is 0 then throw rest[0]
    return this

module.exports = EventEmitter

