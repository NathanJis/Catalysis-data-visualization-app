library(mongolite)
library(dplyr)
library(DT)
#c=mongo(collection = 'iris', db = 'iris', url = "mongodb://m001-student:Temppass1@sandbox-shard-00-01-sfocg.mongodb.net:27017/admin?authSource=admin&readPreference=primaryPreferred&appname=MongoDB%20Compass&ssl=true")
data<-iris #load without mongo id column
shinyUI(
  navbarPage("data visualization app", id = "Page", #defines the type of page layout you want
          tabPanel("filter", #tabpanels are your tabs
                   helpText("This is the filter tab. You can select the columns you want to see and use. After you select columns a search table will show up where you can filter the rows."),
                   checkboxInput("sel_all", "Select all"),
                   checkboxGroupInput("col_sel", "which colums do you want to work with", choices = colnames(data), selected = 'Reaction_code'), #all input fields have a tag for the server to identify, and a description that is displayed on the app. Choices is the things users can select from
                   DTOutput("searchtable"),
                   helpText("Here you can export the displayed data to excel sheets, with a preferred name."),
                   div(style="display:inline-block",textInput("exporttext", "Export name", value = "Export")), #the "div(style = inline-block)" expression allows boxes to exist side by side
                   div(style="display:inline-block",downloadButton(outputId = "download", label ="export excel"))),
          tabPanel("plot",
                   tags$h2("plot"),
                   helpText("This is the plot window with scatterplots, histograms, and boxplots. No data will be displayed if there is none selected in the filter tab. You can select the plot type, plotted columns, and extra columns. You can add linear trendlines to scatterplots and adjust the binwidths of histograms. If you draw a pane over the graph you can see specific points in the graph in the table below."),
                   div(style="display:inline-block",selectInput(inputId = "plottype", label = "which method of plotting", choices = c("scatterplot", "histogram", "boxplot"))),
                   div(style="display:inline-block",selectInput(inputId = "col1", label = "which x column do you want", choices = colnames(data))),
                   div(style="display:inline-block",selectInput(inputId = "col2", label = "which y column do you want", choices = colnames(data))),
                   div(style="display:inline-block",selectInput(inputId = "excol", label = "extra columns", choices = colnames(data), multiple = TRUE)),
                   conditionalPanel( #conditionalpanels show up if certain criteria are met
                     condition = "input.plottype == 'histogram'",
                     numericInput(inputId = "binwidth", label = "select binwidth", 3)
                   ),
                   conditionalPanel(
                     condition = "input.plottype == 'scatterplot'",
                     checkboxInput(inputId = "addtrend", label= tags$strong("add trendline"))
                   ),
                   #DTOutput("plottable"),
                   plotOutput("plot", brush = "plotbrush"), #when you add a brush you can draw panes over data, but you need to give it an ID.
                   conditionalPanel(condition = "input.addtrend != 0 && input.plottype == 'scatterplot'",
                                    verbatimTextOutput("regression")), #this is the statistical data text
                   verbatimTextOutput("summary"),
                   DTOutput("databrush") #table with selected data from plot
                   ),
          tabPanel("GCplot",
                   helpText("This is the GCplot window. It was used in the original app to research if raw gas chromatography data arrays could be plotted in the same app. To display a graph click one of the first three rows in the search table in the filter tab, it will then plot the GCdata column. The lower graph allows you to put your own boundaries on the graph."),
                   tags$h2("Entire GCplot"),
                   plotOutput("GCplot"),
                   tags$h2("Subsettable GCplot"),
                   numericInput("GCxranslider", "select max x", min = 0, max = 1, value = 1), #can add min sliders in the same manner if needed
                   numericInput("GCyranslider", "select max y", min = 0, max = 1, value = 1),
                   plotOutput("subGCplot")
                  )
  )
)
