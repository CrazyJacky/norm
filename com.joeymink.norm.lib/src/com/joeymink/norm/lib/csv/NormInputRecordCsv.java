package com.joeymink.norm.lib.csv;

import java.io.IOException;

import com.csvreader.CsvReader;
import com.joeymink.norm.lib.INormInputRecord;

public class NormInputRecordCsv implements INormInputRecord {

	private CsvReader csvReader;

	public NormInputRecordCsv(CsvReader csvReader) {
		this.csvReader = csvReader;
	}
	
	public String getField(String fieldName) {
		try {
			return csvReader.get(fieldName);
		} catch (IOException e) {
			throw new RuntimeException(e);
		}
	}

}
