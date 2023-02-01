shinyServer(
  function(input,output,session){
    library(ggplot2)
    library(dplyr)
    library(openxlsx)
    library(DT)
    #general
    #c=mongo(collection = 'iris', db = 'iris', url = "mongodb://m001-student:Temppass1@sandbox-shard-00-02-sfocg.mongodb.net:27017/admin?authSource=admin&readPreference=primaryPreferred&appname=MongoDB%20Compass&ssl=true")
    data<-iris
    subdata <- reactive({data[input$searchtable_rows_all,input$col_sel]}) #this is the subsetted data that gets passed to the plot function. Writing some things as reactive functions like here makes them more easily accessible for other code. When used dont forget to add the function brackets ().

    

    #filter
    observe({if (input$sel_all == TRUE) {updateCheckboxGroupInput(session, "col_sel", "which colums do you want to work with", choices = colnames(data), selected = colnames(data))} #updateinput lines adjust your UI reactively. this is also the reason why if your too fast with checking boxes they dissapear sometimes.
      else {updateCheckboxGroupInput(session, "col_sel", "which colums do you want to work with", choices = colnames(data), selected = "Reaction_code")}})
    

    output$searchtable <- renderDT(data[,input$col_sel], filter = 'top')
    
    #export
    
    output$download <- downloadHandler( 
      filename = function(){
        paste(input$exporttext,"xlsx", sep = ".")
      }, content = function(file){
        write.xlsx(subdata(),file)
      }
    ) #the download function is a bit convoluted but if you want to change the file type you just change the extension and write. function.
    
    #plot
    scatterfigure <- reactive(ggplot(data = subdata(), aes(x=eval(parse(text = input$col1)) ,
                                                    y=eval(parse(text = input$col2)))) +
                         geom_point() +
                         xlab(input$col1) + ylab(input$col2) +
                         theme(axis.text.x = element_text(angle = 90))) #this base scatterplot figure is separated because otherwise adding trendlines made the code bulky because it would have to be copied for only one adjustment.
    output$plot <- renderPlot({  #all functions are just ifs and elses, addng new ones is as easy as adding an elsif and making it an option you can select in the UI
      if(input$plottype == "scatterplot"){
        if (input$addtrend == FALSE){scatterfigure()}
        else{scatterfigure()+geom_smooth(method = "glm")}
        
      }
      else if(input$plottype == "histogram") {
        ggplot(data = subdata(), aes(x = eval(parse(text = input$col1)))) + geom_histogram(binwidth = input$binwidth) + xlab(input$col1)
      }
      else if(input$plottype == "boxplot") {
        ggplot(data = subdata(), aes(x = eval(parse(text = input$col1)), y = eval(parse(text = input$col2)))) + geom_boxplot() + xlab(input$col1) + ylab(input$col2)
      }
    }) #ggplot is the base plotting function. You define your data, then the aes function produces a canvas of an appropriate size, things like +geom_histogram or +geom_point define in which format the data is added to the canvas. The rest is just simple labelling
    
    observe({updateSelectInput(session, "col1", choices = colnames(subdata()))})
    observe({updateSelectInput(session, "col2", choices = colnames(subdata()))})
    observe({updateSelectInput(session, "excol", choices = colnames(subdata()))}) #these three make sure the selection for yout plot columns are the same as your selected columns.
    
    plotcol <- reactive({subdata()[,c(input$col1,input$col2, input$excol)]}) #columns passed tot the tables in the plot window
    output$plottable <- renderDT({plotcol()})
    output$regression <- renderPrint(summary(glm(unlist(subdata()[,input$col2]) ~ unlist(subdata()[input$col1])))) #this and the line below pass text to the output variable. if you us verbatimtextoutput in the UI, it will show you the text in the same format as your programming console would.
    output$summary <- renderPrint(summary(subdata()[,input$col1]))
    output$databrush <- renderDT(brushedPoints(subdata() %>% select(input$col1,input$col2, input$excol), brush = input$plotbrush, xvar = input$col1 , yvar = input$col2)) #i think the way this works is that it passes the rows of the selected ponts in the graphs to a table. since it is the same subdata() table it shows the appropriate information
    
    
    #GCplot
    
    GCrow <- reactive((input$searchtable_cell_clicked)$row) #click your row in the search table to get output
    
    output$GCplot <- renderPlot({  # entire figure
      if ('GCdata'%in% colnames(data)){
        number <-GCrow()
        frame <- data.frame(data.frame(data[number,]$GCdata))
        final <- frame[,1]
        ggplot(data = frame, aes(x = 1:length(final), y = as.numeric(final))) +geom_point() + xlab("x")+ ylab('height')
      }})
    output$subGCplot <- renderPlot({ #adjustable figure, minimal values can be added in the same way maximal values are added.
      if ('GCdata'%in% colnames(data)){
        number <-GCrow()
        frame <- data.frame(data.frame(data[number,]$GCdata))
        final <- frame[,1]
        updateNumericInput(session, "GCxranslider", min = 0, max = length(final))
        updateNumericInput(session, "GCyranslider", min = 0, max = max(final))
        ggplot(data = frame, aes(x = 1:length(final), y = as.numeric(final))) +geom_point() + xlab("x")+ ylab('height') +xlim(0,input$GCxranslider) +ylim(0,input$GCyranslider)
      }})
    
  }
)

