package com.joeymink.norm.lib.csv;

import java.io.File;
import java.io.IOException;
import java.util.Iterator;

import com.csvreader.CsvReader;
import com.joeymink.norm.lib.INormInput;
import com.joeymink.norm.lib.INormInputRecord;
import com.joeymink.norm.lib.IoConfig;

public class NormInputCsv implements INormInput, Iterator<INormInputRecord>{
	private CsvReader csvReader;
	private IoConfig config;
	
	public NormInputCsv init() throws IOException {
		File inputFile = new File(config.getProperties().get("file"));
		csvReader = new CsvReader(inputFile.getAbsolutePath());
		csvReader.readHeaders();
		return this;
	}
	
	public Iterator<INormInputRecord> iterator() {
		if (csvReader == null)
			try { init(); } catch(IOException e) { throw new RuntimeException(e); }
		return this;
	}

	// gyrations to support iterator's
	// next() and hasNext() on our CSV
	// input.
	private boolean isNextCached = false;
	private INormInputRecord next;
	private void setNext(INormInputRecord next) {
		this.next = next;
		isNextCached = true;
	}
	private INormInputRecord getAndResetNext() {
		isNextCached = false;
		return next;
	}
	
	public boolean hasNext() {
		if (isNextCached)
			return next != null;
		else {
			setNext(next());
			return next != null;
		}
	}

	public INormInputRecord next() {
		if (isNextCached) {
			return getAndResetNext();
		}
		try {
			if (csvReader.readRecord()) {
				return new NormInputRecordCsv(csvReader);
			}
			return null;
		} catch (IOException e) {
			throw new RuntimeException(e);
		}
	}

	public void remove() {
		throw new UnsupportedOperationException();
	}

	public void setConfig(IoConfig config) {
		this.config = config;
	}
}
