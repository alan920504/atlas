package org.apache.atlas.web.exporter;

import io.prometheus.client.Collector;
import io.prometheus.client.hotspot.*;

import java.util.ArrayList;
import java.util.List;

public class AtlasExporter extends Collector {
    private final List<Collector> collectors = new ArrayList<>();
    private final List<String> globalLabelNames;
    private final List<String> globalLabelValues;
    private volatile boolean isInitialized = false;

    public AtlasExporter(List<String> globalLabelNames, List<String> globalLabelValues) {
        this.globalLabelNames = globalLabelNames;
        this.globalLabelValues = globalLabelValues;
    }

    public synchronized void initialize(){
        if (!isInitialized) {
            addDefaultCollectors();
            isInitialized = true;
        }
    }

    public void addCollector(Collector collector){
        collectors.add(collector);
    }

    private void addDefaultCollectors() {
        this.addCollector(new StandardExports());
        this.addCollector(new MemoryPoolsExports());
        this.addCollector(new MemoryAllocationExports());
        this.addCollector(new BufferPoolsExports());
        this.addCollector(new GarbageCollectorExports());
        this.addCollector(new ThreadExports());
        this.addCollector(new ClassLoadingExports());
        this.addCollector(new VersionInfoExports());
    }

    @Override
    public List<MetricFamilySamples> collect() {
        List<MetricFamilySamples> newMfsList = new ArrayList<>();
        List<MetricFamilySamples.Sample> newSamples;
        List<String> newLabelNames;
        List<String> newLabelValues;
        for (Collector collector: collectors) {
            for (MetricFamilySamples mfs: collector.collect()) {
                newSamples = new ArrayList<>();
                for (MetricFamilySamples.Sample sample: mfs.samples) {
                    newLabelNames = new ArrayList<>(globalLabelNames);
                    newLabelNames.addAll(sample.labelNames);
                    newLabelValues = new ArrayList<>(globalLabelValues);
                    newLabelValues.addAll(sample.labelValues);
                    newSamples.add(new MetricFamilySamples.Sample(sample.name, newLabelNames, newLabelValues,
                            sample.value, sample.timestampMs));
                }
                newMfsList.add(new MetricFamilySamples(mfs.name, mfs.type, mfs.help, newSamples));
            }
        }
        return newMfsList;
    }
}
