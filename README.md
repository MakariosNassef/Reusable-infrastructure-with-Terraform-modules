<p align="center">
  <a href="" rel="noopener">
 <img width=200px height=200px src="https://i.imgur.com/6wj0hh6.jpg" alt="Project logo"></a>
</p>

<h3 align="center">Terrraform Project, Terraform – Module</h3>

<div align="center">

[![Status](https://img.shields.io/badge/status-active-success.svg)]()
[![GitHub Pull Requests](https://img.shields.io/github/issues-pr/kylelobo/The-Documentation-Compendium.svg)](https://github.com/kylelobo/The-Documentation-Compendium/pulls)

</div>

---

<p align="center"> terraform-project-template Deploying Re-usable Code
    <br> 
</p>

## Output
> ![image](https://user-images.githubusercontent.com/28235504/213330832-f59999ef-644c-4e13-86c2-d7fe27cc7fc5.png)

### workspace
> ![image](https://user-images.githubusercontent.com/28235504/213320193-f4a8f15d-fa56-4f6a-918f-02290115cd38.png)


### keyPair
> ![image](https://user-images.githubusercontent.com/28235504/213321400-55b0d52c-099f-46cf-ba11-1922d718fce9.png)

### instances
> ![image](https://user-images.githubusercontent.com/28235504/213321748-f88e4e4f-4da0-4ac6-8ae1-d2e9436e4cc4.png)

> ![image](https://user-images.githubusercontent.com/28235504/213319300-f6b31105-cee6-45be-9357-1013e4a0447f.png)

> ![image](https://user-images.githubusercontent.com/28235504/213319341-7427bb63-1a74-4d75-b8c9-683c3d582233.png)

> ![image](https://user-images.githubusercontent.com/28235504/213319429-e0440997-8b24-466e-9568-0229e72de820.png)



### Target group: Public
> ![image](https://user-images.githubusercontent.com/28235504/213319481-cc8c6a8c-ec2f-4d28-8da1-3576adec2b48.png)

> ![image](https://user-images.githubusercontent.com/28235504/213319751-a3b2c53e-3d36-4265-a9f7-50d4dddc8972.png)

### Target group: Private
> ![image](https://user-images.githubusercontent.com/28235504/213319601-01ceb015-f44c-44d9-992f-e4c79940ab2e.png)

### local exic 
> ![image](https://user-images.githubusercontent.com/28235504/213322268-56ba2f17-01ac-4919-9bec-473c6a8a9bd5.png)
> ![image](https://user-images.githubusercontent.com/28235504/213322522-67237b66-cbba-4a7c-b57e-50aabd5a8f15.png)


### nginx 
``` 
#!/bin/bash
sudo apt update -y
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

sudo unlink /etc/nginx/sites-enabled/default
sudo chmod 777 /etc/nginx/sites-available

sudo echo 'server {
    listen 80;
    location / {
        proxy_pass "http://'$1':80";
    }
}' > /etc/nginx/sites-available/reverse-proxy.conf

sudo ln -s /etc/nginx/sites-available/reverse-proxy.conf /etc/nginx/sites-enabled/reverse-proxy.conf
sudo service nginx restart 
```
### s3 and state file
![image](https://user-images.githubusercontent.com/28235504/213324945-e3db7a87-1300-4e43-afc9-1cbf6dae005b.png)




## ✍️ Author <a name = "Makarios Nassef"></a>

- [@MakariosNassef](https://github.com/MakariosNassef) 


