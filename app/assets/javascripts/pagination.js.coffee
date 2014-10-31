class @Pagination
  @initialize: ->
    $(".pagination a").on 'click', ->
      $.ajax url: @href, dataType: 'script'
      false