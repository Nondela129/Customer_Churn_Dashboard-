#=============== Import Cleaned Dataset ===============#
library(readr)
library(dplyr)

churn_data <- read_csv("C:/Users/HP/Documents/Customer churn dashboard project/churn_data_clean.csv")

#=============== Logistic Regression ===============#
model_logit <- glm(Churn_flag ~ tenure + MonthlyCharges + AvgChargesPerMonth +
                     DSL_flag + Fiber_flag + NoInternet_flag +
                     MonthToMonth_flag + OneYear_flag + TwoYear_flag +
                     PaymentGroup + SeniorCitizen + Bundle_flag,
                   data = churn_data, family = binomial)
summary(model_logit)

#=============== Model Evaluation ===============#
library(caret)

# Confusion matrix
pred_probs <- predict(model_logit, churn_data, type = "response")
pred_class <- ifelse(pred_probs > 0.5, 1, 0)
confusionMatrix(factor(pred_class), factor(churn_data$Churn_flag))

#=============== Visualisation ===============#
library(pROC)

logit_probs <- predict(logit_model, churn_data, type = "response")
roc_logit <- roc(churn_data$Churn_flag, logit_probs)

plot(roc_logit, col = "blue", lwd = 2, main = "ROC Curve - Logistic Regression")
legend("bottomright",
       legend = paste("AUC =", round(auc(roc_logit), 3)),
       col = "blue", lwd = 2)

library(ggplot2)

ggplot(churn_data, aes(x = logit_probs, fill = factor(Churn_flag))) +
  geom_histogram(position = "identity", alpha = 0.6, bins = 30) +
  labs(title = "Predicted Churn Probabilities (Logistic Regression)",
       x = "Predicted Probability of Churn",
       fill = "Actual Churn")

#=============== Export Predictions for Power BI ===============#
churn_data$PredictedProb <- predict(model_logit, churn_data, type = "response")
churn_data$PredictedClass <- ifelse(churn_data$PredictedProb > 0.5, 1, 0)

write_csv(churn_data, "C:/Users/HP/Documents/Customer churn dashboard project/churn_data_with_predictions.csv")


library(pROC)

# Generate ROC curve data
logit_probs <- predict(logit_model, churn_data, type = "response")
roc_logit <- roc(churn_data$Churn_flag, logit_probs)

# Extract coordinates
roc_points <- data.frame(
  FPR = 1 - roc_logit$specificities,
  TPR = roc_logit$sensitivities
)

# Export to Excel/CSV
write.csv(roc_points, "roc_points.csv", row.names = FALSE)


# Generate ROC curve
logit_probs <- predict(logit_model, churn_data, type = "response")
roc_logit <- roc(churn_data$Churn_flag, logit_probs)

# Extract AUC
auc_value <- auc(roc_logit)

# Export AUC to CSV
write.csv(data.frame(AUC = auc_value), "auc_value.csv", row.names = FALSE)

