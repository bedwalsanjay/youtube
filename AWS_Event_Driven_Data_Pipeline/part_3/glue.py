import pandas as pd
from datetime import datetime
# Retrieve input parameters
args = getResolvedOptions(sys.argv, ['bucket_name', 'file_name'])
bucket_name = args['bucket_name']
file_name = args['file_name']

source_s3_url = f"s3://{bucket_name}/{file_name}"

now = datetime.now()
formatted_date_time = int(now.strftime("%Y%m%d%H%M%S"))
target_s3_url="s3://pipeline1-orders/target/orders/"+str(formatted_date_time)+'.parquet'

df = pd.read_csv(source_s3_url)
print(df)

df.drop_duplicates(inplace = True) 
df = df.reset_index(drop=True)
df.to_parquet(target_s3_url)
