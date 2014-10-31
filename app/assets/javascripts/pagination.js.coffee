class @Pagination
  @initialize: ->
    $(".pagination a").on "click", ->
      $.get @href, null, null, "script"
      false