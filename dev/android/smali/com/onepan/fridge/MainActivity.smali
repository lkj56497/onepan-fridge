.class public Lcom/onepan/fridge/MainActivity;
.super Landroid/app/Activity;

.field private web:Landroid/webkit/WebView;

.method public constructor <init>()V
    .registers 1
    invoke-direct {p0}, Landroid/app/Activity;-><init>()V
    return-void
.end method

.method protected onCreate(Landroid/os/Bundle;)V
    .registers 6
    invoke-super {p0, p1}, Landroid/app/Activity;->onCreate(Landroid/os/Bundle;)V
    new-instance v0, Landroid/webkit/WebView;
    invoke-direct {v0, p0}, Landroid/webkit/WebView;-><init>(Landroid/content/Context;)V
    iput-object v0, p0, Lcom/onepan/fridge/MainActivity;->web:Landroid/webkit/WebView;
    invoke-virtual {v0}, Landroid/webkit/WebView;->getSettings()Landroid/webkit/WebSettings;
    move-result-object v1
    const/4 v2, 0x1
    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setJavaScriptEnabled(Z)V
    invoke-virtual {v1, v2}, Landroid/webkit/WebSettings;->setDomStorageEnabled(Z)V
    const-string v3, "file:///android_asset/index.html"
    invoke-virtual {v0, v3}, Landroid/webkit/WebView;->loadUrl(Ljava/lang/String;)V
    invoke-virtual {p0, v0}, Lcom/onepan/fridge/MainActivity;->setContentView(Landroid/view/View;)V
    return-void
.end method

.method public onBackPressed()V
    .registers 3
    iget-object v0, p0, Lcom/onepan/fridge/MainActivity;->web:Landroid/webkit/WebView;
    if-eqz v0, :fallback
    invoke-virtual {v0}, Landroid/webkit/WebView;->canGoBack()Z
    move-result v1
    if-eqz v1, :fallback
    invoke-virtual {v0}, Landroid/webkit/WebView;->goBack()V
    return-void
    :fallback
    invoke-super {p0}, Landroid/app/Activity;->onBackPressed()V
    return-void
.end method
