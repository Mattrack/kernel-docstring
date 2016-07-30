{CompositeDisposable} = require 'atom'

module.exports =
  subscriptions: null

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'kernel-docstring:convert': => @convert()

  deactivate: ->
    @subscriptions.dispose()

  convert: ->
    if editor = atom.workspace.getActiveTextEditor()
      editor.selectAll()
      selection = editor.getSelectedText()
      functions = selection.match(/^([\w]+[ ](?=[\*\w])[*]*\w+(?=[(])\([\w*, ]+\))(?![;])/gm)
      if functions.length > 0
        for target in functions
          test = target.replace /[*]/g, '\\*'
          test = test.replace /[(]/g, '\\('
          test = test.replace /[)]/g, '\\)'
          doc_test = "\\*\\/\\s+" + test + "(?![;])"
          doc_test = new RegExp(doc_test,"m")
          if not doc_test.test(selection)
            re = new RegExp(test,"m");
            function_name = target.match(/\w+(?=[(])/)
            parameters = target.match(/\w+(?=[)]|[,])/g)
            docstring = "/**\n"
            if function_name.length
              for func in function_name
                docstring += " * #{func} -\n"

            if parameters.length
              for param in parameters
                docstring += " * @#{param}:\n"
            docstring += " * Description:\n */\n#{target}"
            selection = selection.replace re, docstring
        console.log(selection)
        editor.insertText(selection)
      else
        console.log("Error: Function is formatted incorrectly. Check with Betty.")
