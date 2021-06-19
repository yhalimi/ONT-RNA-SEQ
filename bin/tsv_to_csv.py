import pandas as pd
import sys

tsv_file='mop_tempdir/counts.tsv'
csv_table=pd.read_table(tsv_file,sep='\t')
csv_table.to_csv('mop_tempdir/counts.csv',index=False)
