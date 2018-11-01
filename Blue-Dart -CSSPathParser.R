
#detach(name, pos = 2L, unload = FALSE, character.only = FALSE,force = FALSE)
#what = 指定database、dataframe等資料型態
#pos = 指定資料位置
#name = 指定資料集名稱
#unload:A logical value indicating whether or not to attempt to unload the namespace when a package is being detached
#force = 是否強制移除，預設值FALSE
detach("package:httr", unload=TRUE)
-------------------------
#httr是用來對伺服器發出連線取得回應的套件
library(httr)
------------------------
#The magrittr package offers pipe %>%
library(magrittr)
--------------------------
#rvest可以幫助您從網頁上抓取信息。 它的設計與magrittr一起使用
#rvest is the convinient xml and css parser
library(rvest)
-----------------------
#整理套件的好工具 tidyverse is good tool for sort out the packages
library(tidyverse)
#if you want to use map(), you should import tidyvesre
#tidyvesre 是由 RStudio 選出多個資料科學應用套件的集合，
#只要使用者暸解呼叫函數與 pipe 運算子 %>% 
#就能夠進行相當實用的資料處理與視覺化，
#這些應用套件包含：
#視覺化文法的王者 ggplot2
#資料處理的利器 dplyr
#長寬表格轉換的專家 tidyr
#資料載入的 readr
#消弭迴圈的加速器 purrr
#強化資料框的 tibble
  
#Step1:get the link string of every complaint
gethref <- function(i){
    url1<-paste("https://www.consumercomplaints.in/blue-dart-express-b100070/page/",i,sep="")
    #搭配for迴圈來產生第1到第i頁的網址。paste是個連接字串的函數
    #最後一個參數sep設定不要有空格就可以讓前面所有參數裡的字串連在一起
    res = url1 %>% GET()
    df = res %>% 
      content(as = "text") %>% 
      read_html() %>% 
      html_nodes(css = "table") %>% 
      map(function(node){
        #node = node %>% as.character() %>% read_html
        list(
          href=node %>% html_node(css = ".complaint>h4>a") %>% html_attr("href")
        )
      })%>% map(unlist)
}


complainthref=list()
#i in 1:157
for(i in 1:1){
  complainthref <- rbind(complainthref,gethref(i))
  Sys.sleep(runif(1,2,2)) 
} 
complainthref %>% View
write.csv(complainthref, "complainthref.csv", row.names = FALSE)

#Step 2:combine the URL
wholeURL= paste("https://www.consumercomplaints.in",complainthref,sep="")
wholeURL
wholeURL %>% View

#Step 3 : get the every complaint content in 2nd layer web page
GetWoleData <- function(i){
  url<-wholeURL[[i]]
  res = url %>% GET()
  res
  res %>% content(as = "text")
  df = res %>% 
    content(as = "text") %>% 
    read_html() %>% 
    html_nodes(css = "table") %>% 
    map(function(node){
      #node = node %>% as.character() %>% read_html
      list(
        title=node %>% html_node(css = ".complaint>h1") %>% html_text()
        ,authoranddate=node %>% html_node(css = ".small") %>% html_text()
        ,complaint=node %>% html_node(css = ".compl-text") %>% html_text()
        ,star=node %>% html_node(css = ".stars-big") %>% html_attr("class")
      )
    }) %>% do.call(rbind,.) %>% as.data.frame() %>% 
    map(unlist) %>% do.call(data.frame,.)
}

#define WholeBDdata is a function of data.frame()
WholeBDdata=data.frame()
# i in 472:3611
#for loop for crawling i pages
# Sys.sleep(runif(1,2,5))若下載太多頁需要讓每次迴圈休息幾秒，
#不然網站會偵測到你讓伺服器負荷太大不讓你下載網頁。
for(i in 4:4){
  WholeBDdata <- rbind.data.frame(WholeBDdata,GetWoleData(i))
  Sys.sleep(runif(1,2,2)) 
  
}   
WholeBDdata %>% View
#save the WholeBDdata as csv
write.csv(WholeBDdata, "WholeBDdata.csv", row.names = FALSE)