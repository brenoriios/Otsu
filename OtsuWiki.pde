color branco = color(255), preto = color(0), vermelho = color(255, 0, 0);
int tam = 256;

String nome = "YinYang";
String ext = "jpg";

void setup(){
  PImage img1;
  
  img1 = loadImage(nome + "." + ext);
  ext = ext.toUpperCase();
  
  PImage contImg1 = contraste(64, 192, img1);
  PImage escImg1 = escurecer(193, 255, img1);
  PImage clarImg1 = clarear(0, 63, img1);
  PImage clar2Img1 = clarear(0, 127, img1);
  
  processar(img1, nome + "\\" + nome);
  processar(contImg1, nome + "Cont" + "\\" + nome + "_Contraste");
  processar(escImg1, nome + "Esc" + "\\" + nome + "_Escurecer");
  processar(clarImg1, nome + "Clar0-63" + "\\" + nome + "_Clarear0-63");
  processar(clar2Img1, nome + "Clar0-127" + "\\" + nome + "_Clarear0-127");

  exit();
}

void processar(PImage img, String id){
  PImage img2, otsu1, otsu2;
  int[] hist1 = new int[tam], hist2 = new int[tam];
  float[] varImg1 = new float[tam], varImg2 = new float[tam];
  
  img.save(nome + ext + "\\" + id + "." + ext);
  
  //Imagem 1 - Construir Histograma
  hist1 = construirHistograma(img, id);
  
  //Imagem 1 - Aplicar Otsu
  otsu1 = otsu(hist1, img, varImg1, id);
  
  //Imagem 1 - Salvar Histograma Usado em Otsu + Variancia Retornada de Otsu
  salvarHistograma(hist1, varImg1, id);
  
  //Otsu Imagem 1 - Construir Histograma
  int[] histOtsuImg1 = construirHistograma(otsu1, id + "_Otsu");
  
  //Otsu Imagem 1 - Salvar Histograma
  salvarHistograma(histOtsuImg1, id + "_Otsu");
  
  print("\n");
  
  //Imagem 2 - Equalizar Histograma Imagem 1
  img2 = equalizar(hist1, img, id);
  
  //Imagem 2 - Construir Histograma
  hist2 = construirHistograma(img2, id + "_Equalizada");
  
  //Imagem 2 - Aplicar Otsu
  otsu2 = otsu(hist2, img2, varImg2, id + "_Equalizada");
  
  //Imagem 2 - Salvar Histograma Usado em Otsu + Variancia Retornada de Otsu
  salvarHistograma(hist2, varImg2, id + "_Equalizada");
  
  //Otsu Imagem 2 - Construir Histograma
  int[] histOtsuImg2 = construirHistograma(otsu2, id + "_Equalizada_Otsu");
  
  //Otsu Imagem 2 - Salvar Histograma
  salvarHistograma(histOtsuImg2, id + "_Equalizada_Otsu");
  
  //Imagem 1 - Salvar Histograma e Variancia
  salvarDados(hist1, varImg1, id);
  
  //Imagem 2 - Salvar Histograma e Variancia
  salvarDados(hist2, varImg2, id + "_Equalizada");
}

void salvarDados(int[] histogram, float[] variancia, String id){
  PrintWriter saida = createWriter(nome + ext + "\\" + id + ".txt");
  
  saida.println("Limiar\tFrequencia\tVariancia");
  
  for(int i = 1; i < tam; i++){
    long tom = int(map(histogram[i], 0, max(histogram), 0, 600));
    long var = int(map(variancia[i-1], 0, max(variancia), 0, 600));
    saida.println(i + "\t" + tom + "\t" + var);
  }
  
  saida.close();
}

PImage contraste(int inicio, int fim, PImage img){
  int meio = inicio + ((fim - inicio) / 2);
  PImage saida = createImage(img.width, img.height, ARGB);
  
  for(int i = 0; i < img.width; i++){
    for(int j = 0; j < img.height; j++){
      float tom = brightness(img.get(i, j));
      if(tom < meio){
        tom = map(tom, inicio, meio - 1, 0, inicio - 1);
      }else{
        tom = map(tom, meio, fim, fim + 1, 255);
      }
      saida.set(i, j, color(tom));
    }
  }
  
  return saida;
}

PImage escurecer(int inicio, int fim, PImage img){
  int var = fim - inicio;
  PImage saida = createImage(img.width, img.height, ARGB);
  
  for(int i = 0; i < img.width; i++){
    for(int j = 0; j < img.height; j++){
      float tom = brightness(img.get(i, j));
      tom = map(tom, inicio, fim, inicio - var, fim - var);
      saida.set(i, j, color(tom));
    }
  }
  
  return saida;
}

PImage clarear(int inicio, int fim, PImage img){
  int var = fim - inicio;
  PImage saida = createImage(img.width, img.height, ARGB);
  
  for(int i = 0; i < img.width; i++){
    for(int j = 0; j < img.height; j++){
      float tom = brightness(img.get(i, j));
      tom = map(tom, inicio, fim, fim + 1, fim + var + 1);
      saida.set(i, j, color(tom));
    }
  }
  
  return saida;
}

PImage equalizar(int vet[], PImage img, String id){
  PImage saida = createImage(img.width, img.height, RGB);
  int[] tons = new int[tam], histogram = vet;
  int total = total(histogram);
  float cProb = 0;
  
  print("Equalizando: " + id + "\n");
  
  for(int i = 0; i < tam; i++){
    cProb += (float)histogram[i] / total;
    tons[i] = round(cProb * 255);
  }
  
  for(int i = 0; i < img.width; i++){
    for(int j = 0; j < img.height; j++){
      int aux = (int)brightness(img.get(i, j));
      color cor = color(tons[aux]);
      saida.set(i, j, cor);
    }
  }
  
  print("Equalização de: " + id + " Finalizada.\n");
  print("Salvando Imagem Equalizada.\n");
  
  saida.save(nome + ext + "\\" + id + "_Equalizada.png");
  
  print("Imagem Equalizada Salva com Sucesso.\n");
  
  return saida;
}

PImage otsu(int histograma[], PImage img, float[] variancia, String id){
  print("Aplicando o Método de Otsu: " + id + "\n");
  
  int T = treshold(histograma, variancia);
  PImage saida = createImage(img.width, img.height, RGB);
  
  for(int i = 0; i < img.width; i++){
    for(int j = 0; j < img.height; j++){
      if(brightness(img.get(i, j)) <= T){
        saida.set(i, j, preto);
      }else{
        saida.set(i, j, branco);
      }
    }
  }
  
  print("Método de Otsu Aplicado com Sucesso: " + id + "\n");
  print("Salvando Imagem Obtida...\n");
  
  saida.save(nome + ext + "\\" + id + "_Otsu.png");
  
  print("Imagem Salva com Sucesso.\n");
  
  return saida;
}

int treshold(int histogramCounts[], float[] var){
  int level = 0;
  long sum1 = 0, sumB = 0, wB = 0, total = total(histogramCounts);
  float maximum = 0.0;
  
  for(int i = 0; i < tam - 1; i++){
    sum1 += i * histogramCounts[i];
  }
  
  for (int i = 1; i < tam; i++){
    long wF = (total - wB);
    
    if (wB > 0 && wF > 0) {
      float mF = ((sum1 - sumB) / wF);
      float fator = ((sumB / wB) - mF);
      float val = wB * wF * pow(fator, 2);
      
      var[i] = val;
      
      if (val >= maximum){
        level = i;
        maximum = val;
      }
    }
    
    wB += histogramCounts[i];
    sumB += (i-1) * histogramCounts[i];
  }
  
  return level;
}

float maximo(float[] vet){
  float maximo = 0.0;
  
  for(int i = 0; i < vet.length; i++){
    if(vet[i] >= maximo){
      maximo = vet[i];
    }
  }
  
  return maximo;
}

int total(int vet[]){
  int total = 0;
  
  for(int i = 0; i < tam; i++){
    total += vet[i];
  }
  
  return total;
}

void exibirVariancia(float curvaVar[], PGraphics saida){ 
  float max = maximo(curvaVar);
  
  saida.stroke(vermelho);
  
  for (int i = 1; i < tam; i++){
    int xAnt = int(map(i-1, 1, 255, 0, saida.width - 1));
    int yAnt = int(map(curvaVar[i-1], 0, max, saida.height - 25, 10));
    
    int xAt = int(map(i, 1, 255, 0, saida.width - 1));
    int yAt = int(map(curvaVar[i], 0, max, saida.height - 25, 10));
    
    saida.line(xAnt, yAnt, xAt, yAt);
  }
}

int[] construirHistograma(PImage img, String id){
  int i, j, cor;
  int[] histograma = new int[tam];
  
  print("Construindo Histograma: " + id + "\n");
  
  for(i = 0; i < img.width; i++){
    for(j = 0; j < img.height; j++){
      cor = (int)brightness(img.get(i,j));
      histograma[cor]++;
    }
  }
  
  if(total(histograma) - (histograma[0] + histograma[255]) != 0){
    histograma[0] = 0;
    histograma[255] = 0;    
  }
  
  print("Histograma Construído com Sucesso.\n");
  
  return histograma;
}

void salvarHistograma(int vet[], float[] variancia, String id){
  int max = 0, j = 0;
  PGraphics saida = createGraphics(1020, 600);
  saida.beginDraw();
  saida.background(225);
  saida.fill(preto);
  saida.textSize(14);
  saida.textAlign(CENTER, BOTTOM);
  saida.rect(0, saida.height - 25, saida.width, 25);
  
  for(int i = 0; i < tam; i++){
    if(vet[i] >= max){
      max = vet[i];
    }
  }
  
  print("Salvando Histograma: " + id + "\n");
  
  for(int i = 0; i < tam; i++){
    int x = int(map(i, 0, 255, 0, saida.width - 1));
    int y = int(map(vet[i], 0, max, saida.height - 25, 10));
    
    saida.line(x, y, x, saida.height - 25);
  }
  
  saida.noStroke();
  
  for (int i = 0; i < tam; i++){
    int x = int(map(i, 0, 255, 0, saida.width - 1));
    if(i == 25 * j){
      saida.fill(branco);
      saida.text(str(i), x, saida.height);
      saida.rect(x, saida.height - 25, 1, 10);
      j++;
    }    
  }
  
  exibirVariancia(variancia, saida);

  print("Histograma Salvo com Sucesso.\n");

  saida.endDraw();
  saida.save(nome + ext + "\\" + id + "_Histograma.png");
}

void salvarHistograma(int vet[], String id){
  int j = 0, max = max(vet);
  PGraphics saida = createGraphics(1020, 600);
  saida.beginDraw();
  saida.fill(preto);
  saida.textSize(14);
  saida.textAlign(CENTER, BOTTOM);
  saida.rect(0, saida.height - 25, saida.width, 25);
  
  print("Salvando Histograma: " + id + "\n");
  
  for(int i = 0; i < tam; i++){
    int x = int(map(i, 0, 255, 0, saida.width - 1));
    int y = int(map(vet[i], 0, max, saida.height - 25, 10));
    
    saida.line(x, y, x, saida.height - 25);
  }
  
  saida.noStroke();
  
  for (int i = 0; i < tam; i++){
    int x = int(map(i, 0, 255, 0, saida.width - 1));
    if(i == 25 * j){
      saida.fill(branco);
      saida.text(str(i), x, saida.height);
      saida.rect(x, saida.height - 25, 1, 10);
      j++;
    }    
  }

  print("Histograma Salvo com Sucesso.\n");

  saida.endDraw();
  saida.save(nome + ext + "\\" + id + "_Histograma.png");
}
