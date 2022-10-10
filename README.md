<p align ="center">
<img width="800" src ="https://user-images.githubusercontent.com/90926044/194941891-dcb27816-0beb-4711-b25a-2a7cb4f05ea4.png">
</p>

![CI/CD](https://github.com/agruezo/CloudResumeChallenge/actions/workflows/main.yml/badge.svg)

---

<h1 align="center">☁️ Cloud Resume Challenge ☁️</h1>

## 📓 Requirements
</br>
The full details of the challenge can be found in the link below:

https://cloudresumechallenge.dev/

</br>

This is a summary of the actual code related tasks I had to complete for the Cloud Resume Challenge:

</br>

1. **HTML**
   - Create a resume site written in HTML

2. **CSS**
   - The resume site should be styled with CSS

3. **Static S3 Website**
   - Deploy as a static S3 website

4. **HTTPS**
   - Make the site secure with HTTPS via an Amazon Cloudfront distribution

5. **DNS**
   - Point a custom DNS domain to the Cloudfront distribution
   - Amazon Route53 was used in my case

6. **JavaScript**
   - Add a visitor counter to the site using JavaScript
   
7. **Database**
   - The visitor counter should have it's count retrieved and updated in a database
   - Amazon DynamoDB was the database of choice

8. **API**
   - Communicate with datbase via an API rather than the JavaScript code itself
   - Amazon API Gateway was used to create the service that triggered an Amazon Lambda function that retrieved and updated the database

9. **Python**
   - Create an Amazon Lambda function using Python that retrieved the count from and updated the count in the database

10. **Tests**
    - Test the code to make sure it is functioning properly
    - A Cypress end-to-end test was used in my case to test the API created

11. **Infrastructure as Code**
    - Provision the API Gateway, Lambda function, and DynamoDB using IaC
    - Terraform was the tool of choice in my case, not only to deploy the API resources, but to also deploy the resume website resources and a custom API domain name as well (Route53, Cloudfront distributions, S3 buckets)

12. **Source Control**
    - Updates should be made automatically rather than through calls from your laptop
    - GitHub was the obvious tool of choice in my case

13. **CI/CD Backend**
    - Any updates to the infrastructure or Python code pushed should automatically be packaged and deployed onto AWS
    - GitHub Actions was used to handle this process

14. **CI/CD Frontend**
    - Any new website code pushed would automatically update the S3 bucket with the new code
    - A Cloudfront invalidation was also triggered after a successful upload to the S3 bucket in order to publish the changes immediately
    - GitHub Actions was also used to handle this process

---

