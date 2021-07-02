proc iml;
	call ExportDataSetToR("SASHELP.CARS","carsR");
	submit / R;
		Model <- lm(MSRP ~ EngineSize + Horsepower + MPG_Highway,
			data=carsR, na.action="na.exclude")
		summary(Model)
		pred <- predict(Model, carsR)
		predict.cars <- cbind(carsR, pred)
	endsubmit;
	call ImportDataSetFromR("WORK.cars_pred","predict.cars");
quit;

proc print data=cars_pred(obs=10);
	var make model MSRP pred;
run;