class @ReportBar

    @show: (data) ->
        leads_per_day = []
        $.each data, (index, value) ->
            leads_per_day.push [ value[0], "#{value[1]}" ]

        plot = $.plot("#leads_per_day", [data: leads_per_day, label: "leads per day"],
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
                $('#tooltip').html(item.series.label + " of " + @.dateFormat(pos.x) + " = " + y).css(
                    top: item.pageY + 5
                    left: item.pageX + 5
                ).fadeIn 200
            else $("#tooltip").hide()



    @dateFormat: (date) ->
        date = new Date(date)
        return (date.getMonth()+1 + "/" + date.getDate() + "/" + date.getFullYear())


    @refresh: (firstDate, secondDate) ->
        $.ajax
            url: "/reports/refresh"
            type: "POST"
            dataType: "json"
            data:
                firstDate: firstDate / 1000
                secondDate: secondDate / 1000

            success: (data) ->
                ReportBar.show data.days
