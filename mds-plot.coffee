
# Calculate a MDS (classic) from a distnace matrix
class MDS
    @distance: (mat, gene_range) ->
        dist = []
        for s1 in [0...mat.strains().length]
            for s2 in [0...mat.strains().length]
                d = 0
                for g in [gene_range[0] .. gene_range[1]]
                    d += Math.abs(mat.presence(s1,g) - mat.presence(s2,g))
                (dist[s1] ||= [])[s2] = d

        # Print as R code!
        #console.log "matrix(c("+dist.map((r) -> ""+r)+"), byrow=T, nrow=#{dist.length}"
        dist



    @cmdscale: (dist) ->
        dist = numeric.pow(dist, 2)        # , done by cmdscale!
        # Function to mean center the rows
        centre = (mat) -> mat.map((r) -> m=numeric.sum(r)/r.length ; numeric.sub(r,m))

        # row and col center matrix
        c = centre(numeric.transpose(centre(dist)))
        c = numeric.neg( numeric.div(c,2) )              # Not sure why, done by cmdscale
        eig = numeric.eig(c)
        order = [0...c.length]
        order.sort((a,b) -> eig.lambda.x[b] - eig.lambda.x[a])
        ev = order.map((i) -> eig.lambda.x[i])
        evec = order.map((i) -> eig.E.x[i])

        dim = (idx) ->
            numeric.mul(numeric.transpose(evec)[idx], Math.sqrt(ev[idx]))

        {xs: dim(0), ys: dim(1) }


# Very simple scatter plot
class ScatterPlot
    width = 300
    right = left = 200
    constructor: (elem, tot_width=width+left+right, tot_height=300) ->
        margin = {top: 20, right: right, bottom: 40, left: left}
        @width = tot_width - margin.left - margin.right
        @height = tot_height - margin.top - margin.bottom

        @x = d3.scale.linear()
               .range([0, @width])

        @y = d3.scale.linear()
               .range([@height, 0])

        @color = d3.scale.category10()

        @xAxis = d3.svg.axis()
                   .scale(@x)
                   .orient("bottom")

        @yAxis = d3.svg.axis()
                   .scale(@y)
                   .orient("left");

        @svg = d3.select(elem).append("svg")
                 .attr("width", @width + margin.left + margin.right)
                 .attr("height", @height + margin.top + margin.bottom)
                .append("g")
                 .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

    # draw(data,labels)
    #   data - array of rows.  First row is all x-coordinates (dimension 1)
    #                          Second row is all y-coordinates (dimension 2)
    #   labels - array of samples.  sample.name, and (sample.parent for colouring)
    draw: (data, labels, dims) ->
        [dim1,dim2] = dims
        @x.domain(d3.extent(data[dim1]))
        @y.domain(d3.extent(data[dim2]))

        # Easier to plot with array of
        locs = d3.transpose(data)

        @svg.selectAll(".axis").remove()
        @svg.append("g")
            .attr("class", "x axis")
            .attr("transform", "translate(0," + @height + ")")
            .call(@xAxis)
          .append("text")
            .attr("class", "label")
            .attr("x", @width)
            .attr("y", 10)
            .style("text-anchor", "start")
            .text("PCA dim #{dim1+1}");

        @svg.append("g")
            .attr("class", "y axis")
            .call(@yAxis)
          .append("text")
            .attr("class", "label")
            .attr("transform", "rotate(-90)")
            .attr("y", 6)
            .attr("dy", ".71em")
            .style("text-anchor", "end")
            .text("PCA dim #{dim2+1}");

        dots = @svg.selectAll(".dot")
                   .data(locs)
        dots.exit().remove()

        # Create the dots and labels
        dot_g = dots.enter().append("g")
                    .attr("class", "dot")
        dot_g.append("circle")
             .attr('class', (d,i) -> "strain-#{i}")
             .attr("r", 3.5)
             .attr("cx",0)
             .attr("cy",0)
             .on("mouseover", (_,i) -> d3.selectAll(".strain-#{i}").classed({'highlight':true}))
             .on("mouseout", (_,i) -> d3.selectAll(".strain-#{i}").classed({'highlight':false}))
             #.style("fill", (d,i) => @color(labels[i].parent))
        dot_g.append("text")
             .attr('class', (d,i) -> "labels strain-#{i}")
             .text((d,i) -> labels[i])
             .attr('x',3)
             .attr('y',-3)
             #.style("fill", (d,i) => @color(labels[i]))

        # Position the dots
        dots.transition()
            .duration(10)
            .attr("transform", (d) => "translate(#{@x(d[dim1])},#{@y(d[dim2])})")


window.MDS = MDS
window.ScatterPlot = ScatterPlot