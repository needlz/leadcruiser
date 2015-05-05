class @LeadStatisticGraph

    @show: (data) ->
        leadsPerDay = @.buildDataForGraph(data)
        @.buildPlot(leadsPerDay)
        @.makeTooltip()


    @buildDataForGraph: (data) ->
      leadsPerDay = []
      $.each data, (index, value) ->
        time = value[0]
        leadsCount = value[1]
        leadsPerDay.push [ time, "#{leadsCount}" ]

    @buildPlot: (data) ->
      plot = $.plot("#leads_per_day", [data: data, label: "Leads per day"],
        series:
          lines:
            show: true
          points:
            show: true
        grid:
          hoverable: true
          clickable: true
        yaxis:
          min: 0
        xaxis:
          show: true
          mode: "time"
          minTickSize: [1, "day"]
      )

    @makeTooltip: ->

        $("<div id='tooltip'></div>").css(
            position: "absolute"
            display: "none"
            border: "1px solid #fdd"
            padding: "2px"
            "background-color": "#fee"
            opacity: 0.80
        ).appendTo "body"

        $("#leads_per_day").bind "plothover", (event, pos, item) =>
            if item
                x = item.datapoint[0]
                y = item.datapoint[1]
                $('#tooltip').html(item.series.label + " of " + @.formatLeadDay(pos.x) + " = " + y).css(
                    top: item.pageY + 5
                    left: item.pageX + 5
                ).fadeIn 200
            else $("#tooltip").hide()



    @formatLeadDay: (day) ->
        date = new Date(day)
        [date.getMonth() + 1, date.getDate(), date.getFullYear()].join('/')


    @refresh: (firstDate, secondDate) ->
        $.ajax
            url: "/reports/refresh"
            type: "GET"
            dataType: "json"
            data:
                firstDate: firstDate
                secondDate: secondDate

            success: (data) ->
              LeadStatisticGraph.show data.days

    @rebuildPage: (firstDate, secondDate) ->
      $.ajax
        url: "/reports"
        type: "GET"
        dataType: "script"
        data:
          firstDate: firstDate
          secondDate: secondDate

class @DatePicker

  @graph_date_range_from = null
  @graph_date_range_to = null
  @table_date_range_from = null
  @table_date_range_to = null

  @initializeForGraph:  ->
#    $(".graph-date-range").dateRangePicker().bind "datepicker-change", (_, period) ->
#      LeadStatisticGraph.refresh period.date1.format("fullUts"), period.date2.format("fullUts")
    LeadStatisticGraph.refresh

  @initializeForLeads: ->
#    $(".table-date-range").dateRangePicker().bind "datepicker-change", (_, period) ->
#      LeadStatisticGraph.rebuildPage period.date1.format("fullUts"), period.date2.format("fullUts")
    LeadStatisticGraph.rebuildPage

  @updateForGraph: ->
    LeadStatisticGraph.refresh DatePicker.graph_date_range_from, DatePicker.graph_date_range_to

  @updateForLeads: ->
    LeadStatisticGraph.rebuildPage DatePicker.table_date_range_from, DatePicker.table_date_range_to
