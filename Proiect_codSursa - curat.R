library(tidyverse)
library(skimr)
info_cumparatori <- read_csv("C:/Users/visan/Desktop/UBB/an3/sem2/Big Data/Proiect/online_shoppers_intention.csv")

head(info_cumparatori)
view(info_cumparatori)

skim(info_cumparatori)
str(info_cumparatori)
glimpse(info_cumparatori)

sum(is.na(info_cumparatori))

table(info_cumparatori$Revenue)
prop.table(table(info_cumparatori$Revenue)) * 100    

sum(duplicated(info_cumparatori))
info_cumparatori_curatat <- info_cumparatori

info_cumparatori_curatat <- info_cumparatori_curatat %>% distinct()
sum(duplicated(info_cumparatori))
sum(duplicated(info_cumparatori_curatat))    

glimpse(info_cumparatori_curatat)
view(info_cumparatori_curatat)

library(dplyr)
info_cumparatori_curatat <- info_cumparatori_curatat %>%
  mutate(across(c(OperatingSystems, Browser, Region, TrafficType, VisitorType, Month, Weekend, Revenue), as.factor))
glimpse(info_cumparatori_curatat)


erori_logice<- info_cumparatori_curatat %>%
  filter(Administrative_Duration < 0 |
           Informational_Duration < 0 |
           ProductRelated_Duration < 0)

nrow(erori_logice)


boxplot(info_cumparatori_curatat$ProductRelated_Duration,
        main="Identificare Outliers: Durata pe paginile de produs",
        col="purple", horizontal=TRUE)

boxplot(info_cumparatori_curatat$Administrative_Duration,
        main="Identificare Outliers: Durata pe paginile administrative",
        col="green", horizontal=TRUE)

boxplot(info_cumparatori_curatat$Informational_Duration,
        main="Identificare Outliers: Durata pe paginile informaționale",
        col="yellow", horizontal=TRUE)


ggplot(data = info_cumparatori_curatat, mapping = aes(x = Revenue, y = PageValues, fill = Revenue)) +
  geom_boxplot() +
  labs(title = "PageValues vs Revenue", x = "Achiziție (Revenue)", y = "Valoarea Paginii (PageValues)")

ggplot(data = info_cumparatori_curatat, mapping = aes(x = VisitorType, fill = Revenue)) +
  geom_bar(position = "dodge") +
  labs(title = "Achiziții în funcție de Tipul Vizitatorului", 
       x = "Tip Vizitator", y = "Număr Sesiuni")

ggplot(data = info_cumparatori_curatat, mapping = aes(x = Month, fill = Revenue)) +
  geom_bar() +
  labs(title = "Vizite pe Luni", x = "Luna", y = "Frecvență (Num. de rânduri de obs.din luna respectiva)")


view(info_cumparatori_curatat)
library(rsample) 
library(caret) 

set.seed(123)
split<- initial_split(info_cumparatori_curatat, prop=0.7, strata="Revenue")
train_data<-training(split) 
test_data<-testing(split)   

table(train_data$Revenue)
table(test_data$Revenue)

library(corrplot) 
date_numerice <- train_data[, sapply(train_data,is.numeric)]
analiza_corelatie <- cor(date_numerice, use="complete.obs")
corrplot(analiza_corelatie, method="circle", title="Matricea de corelație")

train_control <-trainControl(
  method="cv",
  number = 10
)

prop.table(table(train_data$Revenue)) * 100  
prop.table(table(test_data$Revenue)) * 100    

search_grid <- expand.grid( 
  usekernel = c(TRUE,FALSE), 
  fL = 0.5, 
  adjust = seq(0,5, by=1) 
)
mod_nb2 <- train(
  Revenue ~ ., 
  data=train_data, 
  method="nb",
  trControl = train_control, 
  tuneGrid = search_grid 
)

mod_nb2 
confusionMatrix(mod_nb2)


testare_nb<- predict(mod_nb2, newdata = test_data)
conf_matrix_nb<- confusionMatrix(testare_nb, test_data$Revenue)
testare_nb
conf_matrix_nb

library(pROC)
probabilitati_nb <- predict(mod_nb2, newdata = test_data, type="prob")
roc_nb <- roc(test_data$Revenue, probabilitati_nb$`TRUE`)
auc(roc_nb)
plot(roc_nb, col = "blue", lwd = 3, main = "Curba ROC-Naive Bayes")
abline(a=0, b=1, lty=2, col="red")

str(train_data)
summary(train_data)
table(train_data2$Revenue)
prop.table(table(train_data2$Revenue))

library(ggplot2)
ggplot(train_data, aes(x=Revenue, fill = Revenue))+
  geom_bar()+
  labs(title="Distribuția Revenue în setul de antrenament", x="A cumpărat?", y="Nr. vizitatori")


View(train_data)
table(train_data$Browser) 

set.seed(123)
split2<- initial_split(info_cumparatori_curatat, prop=0.7, strata="Revenue")
train_data2<-training(split2) 
test_data2<-testing(split2) 

mod_logistic <- glm(Revenue ~ .,
                    data= train_data2,
                    family = "binomial")
summary(mod_logistic)


test_data2$Browser <- factor(test_data2$Browser, levels = levels(train_data2$Browser))

test_data_final <- na.omit(test_data2)


nivele_acceptate <- mod_logistic$xlevels$Browser

test_data2$Browser <- factor(as.character(test_data2$Browser), levels = nivele_acceptate)

test_data_final <- test_data2[!is.na(test_data2$Browser), ]



interpretare_coef <- exp(coef(mod_logistic))
round(interpretare_coef, 3)

prob_logistica <- predict(mod_logistic, newdata = test_data_final, type = "response")
head(prob_logistica)

pred_logistica_final <- ifelse(prob_logistica > 0.5, "TRUE", "FALSE")
pred_logistica_final <- as.factor(pred_logistica_final)
confusionMatrix(pred_logistica_final, test_data_final$Revenue)

pred_logistica_03 <- ifelse(prob_logistica > 0.3, "TRUE", "FALSE")
pred_logistica_03 <- as.factor(pred_logistica_03)
confusionMatrix(pred_logistica_03, test_data_final$Revenue)

library(pROC)
roc_obj <- roc(test_data_final$Revenue, prob_logistica)
plot(roc_obj, col="blue", lwd=3, main = "ROC - Regresia Logistica")
abline(a=0, b=1, lty=2, col="red")
auc(roc_obj)


summary(mod_logistic)

library(caret)
importanta <- varImp(mod_logistic)
ggplot(importanta, aes(x=reorder(rownames(importanta), Overall), y=Overall)) +
  geom_bar(stat="identity", fill="steelblue") +
  coord_flip() +
  labs(title = "Importanța var în Model", x= "variabile", y = "scor importanță")+
  theme_minimal()
