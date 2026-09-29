#!/bin/python
import sys
import pandas

def read_xlsx(filepath):
    data = pandas.read_excel(
        filepath,
        engine="openpyxl",
        header=0,
        usecols=[
            "Run",
            "condition: Sal",
            "Condition: Oxy",
            "Genotype: SNI",
            "Genotype: Sham"
            ],
        dtype={
            "Run": str,
            "condition: Sal": str,
            "Condition: Oxy": str,
            "Genotype: SNI": str,
            "Genotype: Sham": str
            }
        )
    return data

def read_csv(filepath):
    return pandas.read_csv(filepath, header=0)

def get_condition(row):
    if row['condition: Sal'] == 'x':
        return 'sal'
    elif row['Condition: Oxy'] == 'x':
        return 'oxy'
    else:
        raise ValueError("Found rows where both conditions are missing")

def get_genotype(row):
    if row['Genotype: SNI'] == 'x':
        return 'sni'
    elif row['Genotype: Sham'] == 'x':
        return 'sha'
    else:
        raise ValueError("Found rows where both genotypes are missing")

def print_df(data):
    for idx, row in data.iterrows():
        print(idx, "-", row)

if __name__ == "__main__":
    data = read_xlsx(sys.argv[1])
    data['condition'] = data.apply(get_condition, axis=1)
    data['genotype'] = data.apply(get_genotype, axis=1)
    data.drop(columns=["condition: Sal", "Condition: Oxy"], inplace=True)
    data.drop(columns=["Genotype: SNI", "Genotype: Sham"], inplace=True)
    data.sort_values(by=["genotype", "condition"], inplace=True)
    data = data.reindex(columns=["genotype", "condition", "Run"])
    bases = read_csv(sys.argv[2])
    data = pandas.merge(data, bases, on="Run")
    data.sort_values(by=["Bases", "condition"], inplace=True)
    result = data.to_dict("records")
    [print(i) for i in result]
    print(data.nsmallest(2, "Bases")[["Run"]])
