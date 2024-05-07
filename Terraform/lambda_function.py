import boto3
import datetime

def send_email(sender_email, recipient_email, subject, body):
    ses_client = boto3.client('ses')

    try:
        response = ses_client.send_email(
            Destination={
                'ToAddresses': [
                    recipient_email
                ],
            },
            Message={
                'Body': {
                    'Text': {
                        'Data': body
                    },
                },
                'Subject': {
                    'Data': subject
                },
            },
            Source=sender_email,
        )
    except Exception as e:
        print("Email sending failed. Error:", e)
    else:
        print("Email sent successfully!")

def lambda_handler(event, context):
    sender_email = "your sender email"
    recipient_email = "receiver email"

    subject = "Terraform State Change Report"
    event_record = event.get('Records', [{}])[0] 
    s3_key = event_record.get('s3', {}).get('object', {}).get('key', '')  
    environment = s3_key.split('/')[1] if '/' in s3_key else ''

    body = f"Terraform state change occurred at {datetime.datetime.now()} in environment: {environment}"

    send_email(sender_email, recipient_email, subject, body)

    return 'success'
