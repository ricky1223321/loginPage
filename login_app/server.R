library(shiny)
source("login.R")
shinyServer(function(input, output, session) {
    login = FALSE
    USER <- reactiveValues(login = login)
    observe({ 
        if (USER$login == FALSE) {
            if (!is.null(input$login)) {
                if (input$login > 0) {
                    Username <- isolate(input$userName)
                    Password <- isolate(input$passwd)
                    if(length(which(credentials$username_id==Username))==1) { 
                        pasmatch  <- credentials["passod"][which(credentials$username_id==Username),]
                        pasverify <- password_verify(pasmatch, Password)
                        if(pasverify) {
                            USER$login <- TRUE
                            record = data.frame(
                                username_id=Username,
                                time = Sys.time()
                            )
                            write.table(record,file="record.csv",sep=",",row.names=T,col.names = F, na = "NA",append = TRUE)
                        } else {
                            shinyjs::toggle(id = "nomatch", anim = TRUE, time = 1, animType = "fade")
                            shinyjs::delay(3000, shinyjs::toggle(id = "nomatch", anim = TRUE, time = 1, animType = "fade"))
                        }
                    } else {
                        shinyjs::toggle(id = "nomatch", anim = TRUE, time = 1, animType = "fade")
                        shinyjs::delay(3000, shinyjs::toggle(id = "nomatch", anim = TRUE, time = 1, animType = "fade"))
                    }
                } 
            }
        }    
    })
    
    output$logoutbtn <- renderUI({
        req(USER$login)
        tags$li(a(icon("fa fa-sign-out"), "Logout", 
                  href="javascript:window.location.reload(true)"),
                class = "dropdown", 
                style = "background-color: #eee !important; border: 0;
                    font-weight: bold; margin:5px; padding: 10px;")
    })
    
    output$sidebarpanel <- renderUI({
        if (USER$login == TRUE ){ 
            sidebarMenu(
                menuItem("Main Page", tabName = "dashboard", icon = icon("dashboard")),
                menuItem("Second Page", tabName = "second", icon = icon("th"))
            )
        }
    })
    
    output$body <- renderUI({
        if (USER$login == TRUE ) {
            tabItems(
                
                # First tab
                tabItem(tabName ="dashboard", class = "active",
                        fluidRow(
                            box(width = 12, dataTableOutput('results')),
                            box(dataTableOutput("record"))
                        )),
                
                # Second tab
                tabItem(tabName = "second",
                        fluidRow(
                            box(width = 12, dataTableOutput('results2'))
                        )
                ))
            
        }
        else {
            loginpage
        }
    })
    
    output$results <-  DT::renderDataTable({
        datatable(iris, options = list(autoWidth = TRUE,
                                       searching = FALSE))
    })
    
    output$results2 <-  DT::renderDataTable({
        datatable(mtcars, options = list(autoWidth = TRUE,
                                         searching = FALSE))
    })
})
?password_verify
