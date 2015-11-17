#lang scribble/manual
@require[@for-label[3s
                    lux
                    lux/chaos
                    lux/chaos/3s
                    openal
                    racket/contract/base
                    racket/base]]

@title{3s: positional audio and mixing}
@author{Jay McCarthy}

@defmodule[3s]

The @racketmodname[3s] module provides a system for positional audio
and mixing of sound effects. It is intended for interactive
applications and integrates with @racketmodname[lux]. Presently it
uses the @racketmodname[openal] library, but in principle does not
require its use.

The overall model of @racketmodname[3s] is to parameterize sounds over
the world state, so that sounds created in the past can be
updated (paused, move position, have the content changed, etc) by
initially creating them so that they inspect the world state for cues
to such updates.

The key function, @racket[render-sound], is called regularly (i.e.,
once per tick) and receives the updated world state, along with any
additional sounds created during that tick.

@section{User API Reference}

@defproc[(audio? [x any/c]) boolean?]{Identifies audio content.}

@defproc[(path->audio [p path-string?]) audio?]{Loads audio content from a file given by @racket[p].}

@defstruct*[sound-state ([audio audio?]
                         [posn inexact?]
                         [gain inexact?]
                         [relative? boolean?]
                         [looping? boolean?]
                         [paused? boolean?])]{

A structure specifying the state of a sound. The @racket[audio] field
identifies the audio content of the sound. The @racket[posn] field
identifies the 2D position of the sound, with the @racket[real-part]
of the number as the X coordinate and @racket[imag-part] as the Y
coordinate. The other fields have their obvious interpretation.

}

@defthing[sound-state/c contract?]{Equivalent to @racket[(or/c #f sound-state?)].}
@defthing[sound/c contract?]{Equivalent to @racket[(-> any/c sound-state/c)].}
@defthing[sound-scape/c contract?]{Equivalent to @racket[(listof sound/c)].}

@defproc[(background [a-f (-> any/c audio?)]
                     [#:gain gain inexact? 1.0]
                     [#:pause-f pause-f (-> any/c boolean?) (λ (w) #f)])
         sound/c]{

A sound corresponding to background music. The @racket[a-f] function
selects the audio content based on the world value, while the
@racket[pause-f] function determines whether the sound is paused.

}

@defproc[(sound-at [a audio?]
                   [p inexact?]
                   [#:gain gain inexact? 1.0]
                   [#:looping? looping? boolean? #f]
                   [#:pause-f pause-f (-> any/c boolean?) (λ (w) #f)])
         sound/c]{

A sound located at point @racket[p] with audio content @racket[a]. The
@racket[pause-f] function determines whether the sound is paused.

}

@defproc[(sound-on [a audio?]
                   [p-f (-> any/c inexact?)]
                   [#:gain gain inexact? 1.0]
                   [#:looping? looping? boolean? #f]
                   [#:pause-f pause-f (-> any/c boolean?) (λ (w) #f)])
         sound/c]{

A sound located at the point returned by @racket[p-f] with audio
content @racket[a]. The @racket[pause-f] function determines whether
the sound is paused.

}

@defproc[(sound-until [s sound/c] [until-f (-> any/c boolean?)])
         sound/c]{A sound that plays until @racket[until-f] returns true.}

@section{Internal API Reference}

@defproc[(sound-context? [x any/c]) boolean?]{Identifies sound contexts.}
@defproc[(make-sound-context) sound-context?]{Returns a sound context.}
@defproc[(sound-context-destroy! [sc sound-context?]) void?]{Destroys a sound context, releasing all resources and stopping all sounds.}

@defproc[(system-state? [x any/c]) boolean?]{Identifies the @racketmodname[3s] state.}
@defproc[(initial-system-state [sc sound-context?]) system-state?]{Constructs an initial @racketmodname[3s] state.}
@defproc[(sound-pause! [ss system-state?]) void?]{Pauses all sounds of @racket[ss].}
@defproc[(sound-unpause! [ss system-state?]) void?]{Unpauses all sounds of @racket[ss].}
@defproc[(sound-destroy! [ss system-state?]) void?]{Destroys @racket[ss], releasing all resources and stopping all sounds.}

@defproc[(render-sound [ss system-state?] [scale real?] [lp inexact?] [w any/c] [sounds sound-scape/c]) system-state?]{

Updates all the sounds in @racket[ss] according to the new sound scale
@racket[scale], the new position of the listener @racket[lp], and the
new world value @racket[w], as well initializes all sounds in
@racket[sounds], returning a new @racketmodname[3s] system state.

}

@section{Integrating with lux}

@defmodule[lux/chaos/3s]

@racketmodname[3s] is designed to integrate with @racketmodname[lux]
through the @racketmodname[lux/chaos/3s] module, which provides a
@tech[#:doc '(lib "lux/scribblings/lux.scrbl")]{chaos} for sound
scapes.

@defproc[(make-3s) chaos?]{

Returns a @tech[#:doc '(lib "lux/scribblings/lux.scrbl")]{chaos} that manages sound output.

@racket[word-event] is never called with events from this @tech[#:doc '(lib "lux/scribblings/lux.scrbl")]{chaos}.

The values that @racket[word-output] should return are four element
vectors where the elements correspond to the last four arguments of
@racket[render-sound]: the sound scale, the listener position, the
world value, and the list of new sounds. }
