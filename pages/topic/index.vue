<template>
  <div class="topic" v-loading.fullscreen.lock="loading">
    <w-layout>
      <template #header-text>
        節電話題管理
      </template>
      <!-- <div class="button-container">
        <div class="left">
          <el-button
            class="main-btn"
            :class="{ 'main-btn-unchecked': tableType !== 'topicManagement' }"
          >
            話題管理
          </el-button>
          <el-button
            class="main-btn"
            :class="{ 'main-btn-unchecked': tableType !== 'tableExport' }"
          >
            表單匯出
          </el-button>
        </div>
      </div> -->
      <div
        class="topic-management-title"
        :class="tableType ? 'wishing-rwd' : 'topic-rwd'"
      >
        <div class="left">
          <label
            for=""
            @click="changeTableType(0)"
            :class="{ 'label-unchecked': tableType }"
            >話題管理</label
          >
          <el-divider direction="vertical" />
          <label
            for=""
            @click="changeTableType(1)"
            :class="{ 'label-unchecked': !tableType }"
            >許願池表單</label
          >
        </div>
        <div class="right">
          <el-form
            :inline="true"
            ref="dateForm"
            :model="dateForm"
            :rules="dateFormRules"
            :hide-required-asterisk="true"
            label-width="120px"
          >
            <el-form-item label="查詢區間：" prop="startDate">
              <el-date-picker
                placeholder="請選擇日期"
                v-model="dateForm.startDate"
                type="month"
                style="width: 200px;"
                format="yyyy/MM"
                :picker-options="editStartOptions"
              ></el-date-picker>
            </el-form-item>
            <el-form-item>
              <label class="el-form-item__label" style="padding: 0 0.5rem;"
                >至</label
              >
            </el-form-item>
            <el-form-item prop="endDate">
              <el-date-picker
                placeholder="請選擇日期"
                v-model="dateForm.endDate"
                type="month"
                style="width: 200px;"
                format="yyyy/MM"
                :picker-options="editStopOptions"
              ></el-date-picker>
            </el-form-item>
            <el-form-item>
              <el-button @click="validateDate('dateForm')">查詢</el-button>
              <el-button @click="resetData" class="clear-btn">清空</el-button>
              <el-button @click="excel">下載</el-button>
              <el-button
                style="padding: 0 2.2rem;"
                class="hidden-btn"
                v-if="!tableType"
                @click="showAddDialog = true"
              >
                <img
                  :src="require('@/assets/img/common/icon-plus.svg')"
                  alt=""
                  style="vertical-align: sub;"
                />
                新增話題
              </el-button>
            </el-form-item>
          </el-form>
        </div>
      </div>
      <el-table
        v-if="!tableType"
        :data="topicData"
        border
        stripe
        style="width: 100%;"
      >
        <!-- <el-table-column prop="order" label="排序" width="130">
          <template slot-scope="scope">
            <p>{{ scope.row.order }}</p>
          </template>
        </el-table-column> -->
        <el-table-column prop="topicTitle" label="話題" min-width="15%">
        </el-table-column>
        <el-table-column prop="lineGroup" label="嵌入網址" min-width="30%">
        </el-table-column>
        <el-table-column prop="createAt" label="建立時間" min-width="25%">
        </el-table-column>
        <el-table-column label="操作" width="220">
          <template slot-scope="scope">
            <el-button
              class="small-btn edit-btn"
              @click="openEditDialog(scope.row)"
              type="text"
              >編輯</el-button
            >
            <el-button
              class="small-btn delete-btn"
              @click="openDeleteDialog(scope.row.id)"
              type="text"
              >刪除</el-button
            >
          </template>
        </el-table-column>
      </el-table>
      <el-table v-else :data="wishingData" border stripe style="width: 100%;">
        <el-table-column prop="userId" label="用戶ID" min-width="15%">
          <template slot-scope="scope">
            <p>{{ scope.row.userId }}</p>
          </template>
        </el-table-column>
        <el-table-column prop="message" label="文字內容" min-width="30%">
        </el-table-column>
        <el-table-column prop="createAt" label="建立時間" min-width="25%">
        </el-table-column>
        <el-table-column label="操作" width="220">
          <template slot-scope="scope">
            <el-button
              class="small-btn hidden-btn"
              :class="{ 'edit-btn': !scope.row.status }"
              @click="editWishing(scope.row)"
              type="text"
            >
              {{ !scope.row.status ? "啟用" : "隱藏" }}
            </el-button>
            <el-button
              class="small-btn delete-btn"
              @click="openDeleteDialog(scope.row.id)"
              type="text"
              >刪除</el-button
            >
          </template>
        </el-table-column>
      </el-table>
      <el-pagination
        v-if="!tableType"
        background
        layout="prev, pager, next"
        :page-count="topicPageCount"
        :current-page="topicCurrentPage"
        :pager-count="7"
        @current-change="topicCurrentChange"
      />
      <el-pagination
        v-else
        background
        layout="prev, pager, next"
        :page-count="wishingPageCount"
        :current-page="wishingCurrentPage"
        :pager-count="7"
        @current-change="wishingCurrentChange"
      />

      <el-dialog
        title="新增"
        :visible.sync="showAddDialog"
        custom-class="topic-dialog"
        :close-on-click-modal="false"
        :close-on-press-escape="false"
        :before-close="addDialogClose"
      >
        <el-form
          ref="addForm"
          :model="addForm"
          :rules="addFormRules"
          :hide-required-asterisk="true"
          label-width="110px"
          label-position="top"
        >
          <el-form-item label="話題" prop="topic">
            <el-input
              v-model="addForm.topic"
              placeholder="請輸入話題"
            ></el-input>
          </el-form-item>
          <el-form-item label="嵌入網址" prop="url">
            <el-input
              v-model.trim="addForm.url"
              placeholder="請輸入嵌入網址"
            ></el-input>
          </el-form-item>
        </el-form>
        <span slot="footer" class="dialog-footer">
          <el-button @click="resetForm('addForm'), (showAddDialog = false)"
            >取消</el-button
          >
          <el-button @click="validateForm('addForm')">確定</el-button>
        </span>
      </el-dialog>

      <el-dialog
        title="編輯"
        :visible.sync="showEditDialog"
        custom-class="topic-dialog"
        :close-on-click-modal="false"
        :close-on-press-escape="false"
        :before-close="editDialogClose"
      >
        <el-form
          ref="editForm"
          :model="editForm"
          :rules="editFormRules"
          :hide-required-asterisk="true"
          label-width="110px"
          label-position="top"
        >
          <el-form-item label="話題" prop="topic">
            <el-input
              v-model="editForm.topic"
              placeholder="請輸入話題"
            ></el-input>
          </el-form-item>
          <el-form-item label="嵌入網址" prop="url">
            <el-input
              v-model.trim="editForm.url"
              placeholder="請輸入嵌入網址"
            ></el-input>
          </el-form-item>
          <el-form-item label="設定" prop="status">
            <el-radio v-model="editForm.status" :label="1">顯示</el-radio>
            <el-radio v-model="editForm.status" :label="0">隱藏</el-radio>
          </el-form-item>
        </el-form>
        <span slot="footer" class="dialog-footer">
          <el-button @click="resetForm('editForm'), (showEditDialog = false)"
            >取消</el-button
          >
          <el-button @click="validateForm('editForm')">確定</el-button>
        </span>
      </el-dialog>

      <el-dialog
        title="刪除"
        :visible.sync="showDeleteDialog"
        :close-on-click-modal="false"
        :close-on-press-escape="false"
        custom-class="topic-dialog"
      >
        <p class="single-text">確定刪除此筆資料</p>
        <span slot="footer" class="dialog-footer">
          <el-button @click="showDeleteDialog = false">取消</el-button>
          <el-button @click="deleteTopics">確定</el-button>
        </span>
      </el-dialog>
    </w-layout>
  </div>
</template>
<script>
import WLayout from '@/components/Layout';
import backendApi from '@/assets/js/api/backendApi.js';
import helper from '@/assets/js/util/helper';
import dayjs from 'dayjs';

export default {
  components: {
    WLayout,
  },
  data() {
    return {
      dateForm: {
        startDate: '',
        endDate: '',
      },
      dateFormRules: {
        startDate: [
          {
            type: 'date',
            required: true,
            message: '請輸入開始日期',
            trigger: 'blur',
          },
        ],
        endDate: [
          {
            type: 'date',
            required: true,
            message: '請輸入結束日期',
            trigger: 'blur',
          },
        ],
      },
      editStartOptions: {
        disabledDate: (time) => {
          if (!this.dateForm.endDate) {
            return time.getTime() < new Date(1970 - 1 - 1).getTime(); // 禁止選擇1970年以前的日期
          }
          return time.getTime() > new Date(this.dateForm.endDate);
        },
      },
      editStopOptions: {
        disabledDate: (time) => time.getTime() < new Date(this.dateForm.startDate)
          || time.getTime() < new Date(1970 - 1 - 1).getTime(), // 禁止選擇1970年以前的日期
      },
      addForm: {
        topic: '',
        url: '',
      },
      deleteId: '',
      addFormRules: {
        topic: [{ required: true, message: '請輸入話題', trigger: 'blur' }],
        url: [{ required: true, message: '請輸入嵌入網址', trigger: 'blur' }],
      },
      editForm: {
        id: '',
        topic: '',
        url: '',
        status: '',
      },
      editFormRules: {
        topic: [{ required: true, message: '請輸入話題', trigger: 'blur' }],
        url: [{ required: true, message: '請輸入嵌入網址', trigger: 'blur' }],
        status: [{ required: true, message: '請選擇話題狀態', trigger: 'blur' }],
      },
      tableType: 0,
      topicData: [],
      wishingData: [],
      showAddDialog: false,
      showEditDialog: false,
      showDeleteDialog: false,
      loading: false,
      topicCurrentPage: 1,
      topicPageCount: 1,
      wishingCurrentPage: 1,
      wishingPageCount: 1,
      size: 10,
      searchingDate: {
        startDate: '',
        endDate: '',
      },
    };
  },
  mounted() {
    const vm = this;
    vm.getTopics();
  },
  methods: {
    async getTopics() {
      const vm = this;
      vm.loading = true;
      let data = {};
      data = vm.sendApiData();

      const res = await backendApi.getTopics(data);
      if (res.code === 200) {
        vm.topicData = [];
        vm.topicCurrentPage = res.data.pageNumber;
        vm.topicPageCount = res.data.totalPages;
        res.data.content.forEach((e) => {
          vm.objectElementFilter(e);
          vm.topicData.push(e);
        });
      } else {
        vm.$message({
          message: res.message,
          type: 'error',
        });
      }
      vm.loading = false;
    },
    async getWishingPond() {
      const vm = this;
      vm.loading = true;
      let data = {};
      data = vm.sendApiData();
      const res = await backendApi.getWishingPond(data);
      if (res.code === 200) {
        vm.wishingData = [];
        vm.wishingCurrentPage = res.data.pageNumber;
        vm.wishingPageCount = res.data.totalPages;
        res.data.content.forEach((e) => {
          vm.objectElementFilter(e);
          vm.wishingData.push(e);
        });
      } else {
        vm.$message({
          message: res.message,
          type: 'error',
        });
      }
      vm.loading = false;
    },
    async addTopics() {
      const vm = this;
      vm.loading = true;
      const data = {
        topicTitle: vm.addForm.topic,
        lineGroup: vm.addForm.url,
        status: 1,
      };
      const res = await backendApi.addTopics(data);
      if (res.code === 200) {
        vm.resetData();
        vm.resetForm('addForm');
        vm.showAddDialog = false;
      }
      vm.loading = false;
    },
    async editTopics() {
      const vm = this;
      vm.loading = true;
      const data = {
        id: vm.editForm.id,
        topicTitle: vm.editForm.topic,
        lineGroup: vm.editForm.url,
        status: vm.editForm.status,
      };
      const res = await backendApi.editTopics(data);
      if (res.code === 200) {
        vm.getTopics();
        vm.resetForm('editForm');
        vm.showEditDialog = false;
      }
      vm.loading = false;
    },
    async editWishing(row) {
      const vm = this;
      vm.loading = true;
      const data = {
        id: row.id,
        status: row.status ? 0 : 1,
      };
      const res = await backendApi.editWishingPond(data);
      if (res.code === 200) {
        vm.getWishingPond();
      }
      vm.loading = false;
    },
    async deleteTopics() {
      const vm = this;
      vm.loading = true;
      let res = '';
      const data = {
        id: vm.deleteId,
      };
      if (!vm.tableType) {
        res = await backendApi.deleteTopics(data);
      } else {
        res = await backendApi.deleteWishingPond(data);
      }
      if (res.code === 200) {
        vm.deleteId = '';
        vm.resetData();
        vm.showDeleteDialog = false;
      }
      vm.loading = false;
    },
    async excel() {
      const vm = this;
      vm.loading = true;
      let res = '';
      let data = {};
      let title = '';
      data = vm.sendApiData();
      if (!vm.tableType) {
        title = '話題管理表單.xlsx';
        res = await backendApi.getTopicExcel(data);
      } else {
        title = '許願池表單.xlsx';
        res = await backendApi.getWishingPondExcel(data);
      }
      if (res) {
        const a = document.createElement('a');
        const blob = new Blob([res], { type: 'application/excel' });
        a.href = window.URL.createObjectURL(blob);
        a.download = title;
        a.style.display = 'none';
        document.body.appendChild(a);
        a.click();
      }
      vm.loading = false;
    },
    openEditDialog(row) {
      const vm = this;
      vm.showEditDialog = true;
      const cloneData = JSON.parse(JSON.stringify(row));
      vm.editForm.id = cloneData.id;
      vm.editForm.topic = cloneData.topicTitle;
      vm.editForm.url = cloneData.lineGroup;
      vm.editForm.status = cloneData.status;
    },
    openDeleteDialog(id) {
      const vm = this;
      vm.showDeleteDialog = true;
      vm.deleteId = id;
    },
    validateDate(formName) {
      const vm = this;
      vm.$refs[formName].validate((valid) => {
        if (valid) {
          vm.searchingDate = JSON.parse(JSON.stringify(vm.dateForm));
          if (!vm.tableType) {
            vm.topicCurrentPage = 1;
            vm.getTopics();
          } else {
            vm.wishingCurrentPage = 1;
            vm.getWishingPond();
          }
        }
        return false;
      });
    },
    validateForm(formName) {
      const vm = this;
      vm.$refs[formName].validate((valid) => {
        if (valid) {
          switch (formName) {
            case 'addForm':
              vm.addTopics();
              break;
            case 'editForm':
              vm.editTopics();
              break;
            default:
              break;
          }
        }
        return false;
      });
    },
    resetForm(formName) {
      const vm = this;
      vm.$refs[formName].resetFields();
      if (formName === 'editForm') {
        Object.keys(vm.editForm).forEach((key) => {
          vm.editForm[key] = '';
        });
      }
    },
    addDialogClose(done) {
      const vm = this;
      vm.resetForm('addForm');
      done();
    },
    editDialogClose(done) {
      const vm = this;
      vm.resetForm('editForm');
      done();
    },
    changeTableType(type) {
      const vm = this;
      // 0為話題管理 1為許願池表單
      vm.tableType = type;
      vm.searchingDate = {};
      vm.resetForm('dateForm');
      if (!type) {
        vm.topicCurrentPage = 1;
        vm.getTopics();
      } else {
        vm.wishingCurrentPage = 1;
        vm.getWishingPond();
      }
    },
    topicCurrentChange(val) {
      const vm = this;
      vm.topicCurrentPage = val;
      vm.getTopics();
    },
    wishingCurrentChange(val) {
      const vm = this;
      vm.wishingCurrentPage = val;
      vm.getWishingPond();
    },
    chooseLastDate(day) {
      const date = String(dayjs(day).format('YYYY-MM-DD'));
      const dateNumber = dayjs(date).daysInMonth();
      const dateArray = date.split('-');
      dateArray[dateArray.length - 1] = dateNumber;
      return dateArray.join('-');
    },
    objectElementFilter(object) {
      Object.keys(object).forEach((key) => {
        if (!object[key] && key !== 'status') {
          object[key] = '-';
        }
      });
      if (object.createAt !== '-') {
        object.createAt = helper.transformTime(object.createAt, 1);
      }
    },
    resetData() {
      const vm = this;
      vm.searchingDate.startDate = '';
      vm.searchingDate.endDate = '';
      vm.dateForm.startDate = '';
      vm.dateForm.endDate = '';
      vm.topicCurrentPage = 1;
      vm.wishingCurrentPage = 1;
      if (!vm.tableType) {
        vm.getTopics();
      } else {
        vm.getWishingPond();
      }
    },
    sendApiData() {
      const vm = this;
      let data = '';
      const currentPage = !vm.tableType
        ? vm.topicCurrentPage
        : vm.wishingCurrentPage;
      if (vm.searchingDate.startDate && vm.searchingDate.endDate) {
        data = {
          page: currentPage,
          size: vm.size,
          startDate: dayjs(vm.searchingDate.startDate).format('YYYY-MM-DD'),
          endDate: vm.chooseLastDate(vm.searchingDate.endDate),
        };
      } else {
        data = {
          page: currentPage,
          size: vm.size,
        };
      }
      return data;
    },
  },
};
</script>
<style lang="scss" scoped>
.button-container {
  display: flex;
  justify-content: space-between;
}

.topic-management-title {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 25px;

  label {
    color: #23354d;
    font-weight: bold;
    font-size: 1.125rem;
    letter-spacing: 3.6px;
    cursor: pointer;
  }

  .label-unchecked {
    color: #b5b5b5;
  }
}

/deep/ .order-input.el-input {
  width: 70px;
  margin-left: -0.9rem;

  .el-input__inner {
    height: 1.875rem;
    padding: 0 0.75rem;
    border: solid 0.15rem #b5b5b5;
    border-radius: unset;
    line-height: 1.875rem;
    letter-spacing: 1.6px;
    background-color: transparent;
  }
}

/deep/ .el-table {
  margin-top: 1.5625rem;
}

/deep/ .filter-bar {
  margin-bottom: 1rem;
}

/deep/ .el-divider--vertical {
  width: 0.3625rem;
  height: 1.8rem;
  margin: 0 1rem;
  border-radius: 28.5%;
  background-color: #23354d;
}

/deep/ .el-button.main-btn {
  border: solid 0.15rem #ffba31;
  background-color: #ffba31;
}

/deep/ .el-button.main-btn-unchecked {
  border: solid 0.15rem #ffba31;
  color: #ffba31;
  background-color: #fff;
}

.add-btn {
  background-color: #67bcc2;
}

.hidden-btn {
  background-color: #67bcc2;
}

.edit-btn {
  background-color: #ffba31;
}

.delete-btn {
  background-color: #9e3131;
}

.clear-btn {
  background-color: #ccc;

  &:hover {
    background-color: #949494;
  }
}

/deep/ .el-dialog.topic-dialog {
  .single-text {
    width: fit-content;
    margin: 0 auto;
    color: #333;
    font-weight: bold;
    font-size: 1rem;
    letter-spacing: 1.6px;
  }

  .el-dialog__body {
    padding: 0 6.25rem 1.875rem;
  }

  .el-input {
    width: 100%;
  }

  .el-input__inner {
    font-size: 1.125rem;
    letter-spacing: 1.8px;
  }

  .el-form-item__label {
    padding: 0;
    font-size: 1.25rem;
  }

  .el-dialog__footer {
    padding: 0.625rem 1.25rem 2.2rem;
  }
}

@media screen and(max-width: 1790px) {
  .topic-management-title {
    display: block;

    .left {
      margin-bottom: 1.5625rem;
    }

    /deep/ .el-form-item__label {
      letter-spacing: 0.225rem;
      text-align: left;
    }
  }
}

@media screen and(max-width: 1610px) {
  .topic-rwd {
    display: block;

    .left {
      margin-bottom: 1.5625rem;
    }

    /deep/ .el-form-item__label {
      letter-spacing: 0.225rem;
      text-align: left;
    }
  }
}

@media screen and(max-width: 1538px) {
  .topic-rwd {
    /deep/ .el-form {
      .el-form-item {
        &:last-child {
          margin-top: 1.5625rem;
        }
      }
    }
  }
}

@media screen and(max-width: 1333px) {
  .wishing-rwd {
    /deep/ .el-form {
      .el-form-item {
        &:last-child {
          margin-top: 1.5625rem;
        }
      }
    }
  }
}
</style>
