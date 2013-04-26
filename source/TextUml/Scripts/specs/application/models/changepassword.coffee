﻿define (require) ->
  _               = require 'underscore'
  ChangePassword  = require '../../../application/models/changepassword'
  repeatString    = require('../../helpers').repeatString

  describe 'models/changepassword', ->
    changePassword = null

    beforeEach -> changePassword = new ChangePassword

    describe '#defaults', ->

      it 'has #oldPassword', ->
        expect(changePassword.defaults()).to.have.property 'oldPassword'

      it 'has #newPassword', ->
        expect(changePassword.defaults()).to.have.property 'newPassword'

      it 'has #confirmPassword', ->
        expect(changePassword.defaults()).to.have.property 'confirmPassword'

    describe '#url', ->
      it 'is set', -> expect(changePassword.url).to.exist

    describe 'validation', ->

      describe 'valid', ->
        beforeEach ->
          changePassword.set
            oldPassword       : 'secret'
            newPassword       : '$ecre8'
            confirmPassword   : '$ecre8'

        it 'is valid', -> expect(changePassword.isValid()).to.be.ok
       
      describe 'invalid', ->
        
        describe '#oldPassword', ->
          
          describe 'missing', ->
            beforeEach ->
              changePassword.set
                newPassword       : '$ecre8'
                confirmPassword   : '$ecre8'

            it 'is invalid', ->
              expect(changePassword.isValid()).to.not.be.ok
              expect(changePassword.validationError)
                .to.have.property 'oldPassword'
 
          describe 'blank', ->
            beforeEach ->
              changePassword.set
                oldPassword       : ''
                newPassword       : '$ecre8'
                confirmPassword   : '$ecre8'

            it 'is invalid', ->
              expect(changePassword.isValid()).to.not.be.ok
              expect(changePassword.validationError)
                .to.have.property 'oldPassword'

        describe '#newPassword', ->
          
          describe 'missing', ->
            beforeEach ->
              changePassword.set
                oldPassword       : 'secret'
                confirmPassword   : '$ecre8'

            it 'is invalid', ->
              expect(changePassword.isValid()).to.not.be.ok
              expect(changePassword.validationError)
                .to.have.property 'newPassword'
 
          describe 'blank', ->
            beforeEach ->
              changePassword.set
                oldPassword       : 'secret'
                newPassword       : ''
                confirmPassword   : '$ecre8'

            it 'is invalid', ->
              expect(changePassword.isValid()).to.not.be.ok
              expect(changePassword.validationError)
                .to.have.property 'newPassword'

          describe 'less than minimum length', ->
            beforeEach ->
              changePassword.set
                oldPassword       : 'secret'
                newPassword       : repeatString 5
                confirmPassword   : '$ecre8'

            it 'is invalid', ->
              expect(changePassword.isValid()).to.not.be.ok
              expect(changePassword.validationError)
                .to.have.property 'newPassword'

          describe 'more than maximum length', ->
            beforeEach ->
              changePassword.set
                oldPassword       : 'secret'
                newPassword       : repeatString 65
                confirmPassword   : '$ecre8'

            it 'is invalid', ->
              expect(changePassword.isValid()).to.not.be.ok
              expect(changePassword.validationError)
                .to.have.property 'newPassword'

        describe '#confirmPassword', ->
          
          describe 'missing', ->
            beforeEach ->
              changePassword.set
                oldPassword   : 'secret'
                newPassword   : '$ecre8'

            it 'is invalid', ->
              expect(changePassword.isValid()).to.not.be.ok
              expect(changePassword.validationError)
                .to.have.property 'confirmPassword'
 
          describe 'blank', ->
            beforeEach ->
              changePassword.set
                oldPassword       : 'secret'
                newPassword       : '$ecre8'
                confirmPassword   : ''

            it 'is invalid', ->
              expect(changePassword.isValid()).to.not.be.ok
              expect(changePassword.validationError)
                .to.have.property 'confirmPassword'

          describe 'do not match', ->
            beforeEach ->
              changePassword.set
                oldPassword       : 'secret'
                newPassword       : '$ecre8'
                confirmPassword   : 'foo bar'

            it 'is invalid', ->
              expect(changePassword.isValid()).to.not.be.ok
              expect(changePassword.validationError)
                .to.have.property 'confirmPassword'